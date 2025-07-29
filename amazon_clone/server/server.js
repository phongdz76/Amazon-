// server.js - WebSocket Server cho Live Stream
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

app.use(cors());
app.use(express.json());

// Live stream state
let streamState = {
  isActive: false,
  status: 'offline', // 'offline', 'starting', 'live', 'ending'
  products: [],
  viewers: 0,
  startTime: null,
  adminSocketId: null
};

// Store connected clients
let connectedClients = new Map();

io.on('connection', (socket) => {
  console.log(`🔗 Client connected: ${socket.id}`);
  
  // Send current stream state to new client
  socket.emit('stream_state', streamState);

  // Admin joins as streamer
  socket.on('admin_join', (data) => {
    console.log('👨‍💼 Admin joined:', data);
    streamState.adminSocketId = socket.id;
    connectedClients.set(socket.id, { type: 'admin', ...data });
    
    // Notify all clients about admin presence
    socket.broadcast.emit('admin_connected', {
      message: 'Admin has joined the stream'
    });
  });

  // User joins as viewer
  socket.on('user_join', (data) => {
    console.log('👤 User joined:', data);
    connectedClients.set(socket.id, { type: 'user', ...data });
    
    if (streamState.isActive && streamState.status === 'live') {
      streamState.viewers++;
      // Notify all clients about viewer count update
      io.emit('viewer_update', {
        viewers: streamState.viewers
      });
    }
  });

  // Admin starts stream
  socket.on('start_stream', (data) => {
    if (connectedClients.get(socket.id)?.type === 'admin') {
      console.log('🔴 Starting live stream with', data.products?.length || 0, 'products');
      
      streamState.status = 'starting';
      streamState.products = data.products || [];
      
      // Notify all clients stream is starting
      io.emit('stream_starting', {
        status: 'starting',
        products: streamState.products
      });

      // After 2 seconds, go live
      setTimeout(() => {
        streamState.isActive = true;
        streamState.status = 'live';
        streamState.startTime = new Date();
        streamState.viewers = 1; // Admin counts as viewer

        console.log('🟢 Stream is now LIVE!');
        
        io.emit('stream_live', {
          status: 'live',
          isActive: true,
          products: streamState.products,
          viewers: streamState.viewers,
          startTime: streamState.startTime
        });
      }, 2000);
    }
  });

  // Admin updates products during stream
  socket.on('update_products', (data) => {
    if (connectedClients.get(socket.id)?.type === 'admin' && streamState.isActive) {
      console.log('📦 Admin updated products:', data.products?.length || 0);
      streamState.products = data.products || [];
      
      io.emit('products_updated', {
        products: streamState.products
      });
    }
  });

  // Admin ends stream
  socket.on('end_stream', () => {
    if (connectedClients.get(socket.id)?.type === 'admin') {
      console.log('🔴 Admin ending stream...');
      
      streamState.status = 'ending';
      io.emit('stream_ending', { status: 'ending' });

      setTimeout(() => {
        streamState.isActive = false;
        streamState.status = 'offline';
        streamState.products = [];
        streamState.viewers = 0;
        streamState.startTime = null;
        streamState.adminSocketId = null;

        console.log('⚫ Stream ended');
        
        io.emit('stream_ended', {
          status: 'offline',
          isActive: false,
          products: [],
          viewers: 0
        });
      }, 1000);
    }
  });

  // Handle user cart actions
  socket.on('add_to_cart', (data) => {
    console.log('🛒 User added to cart:', data.productName);
    
    // Notify admin about cart activity
    if (streamState.adminSocketId) {
      io.to(streamState.adminSocketId).emit('cart_activity', {
        action: 'add_to_cart',
        product: data.product,
        userId: socket.id
      });
    }
  });

  // Heartbeat to keep connection alive
  socket.on('ping', () => {
    socket.emit('pong');
  });

  // Handle disconnect
  socket.on('disconnect', () => {
    console.log(`❌ Client disconnected: ${socket.id}`);
    
    const client = connectedClients.get(socket.id);
    
    if (client) {
      if (client.type === 'admin') {
        // Admin disconnected, end stream
        streamState.isActive = false;
        streamState.status = 'offline';
        streamState.products = [];
        streamState.viewers = 0;
        streamState.startTime = null;
        streamState.adminSocketId = null;
        
        socket.broadcast.emit('admin_disconnected', {
          message: 'Admin has left the stream'
        });
        
        socket.broadcast.emit('stream_ended', {
          status: 'offline',
          isActive: false,
          products: [],
          viewers: 0
        });
      } else if (client.type === 'user' && streamState.viewers > 0) {
        // User disconnected, decrease viewer count
        streamState.viewers--;
        io.emit('viewer_update', {
          viewers: streamState.viewers
        });
      }
      
      connectedClients.delete(socket.id);
    }
  });
});

// REST API endpoints for debugging
app.get('/stream/status', (req, res) => {
  res.json(streamState);
});

app.get('/stream/clients', (req, res) => {
  const clients = Array.from(connectedClients.entries()).map(([id, data]) => ({
    id,
    ...data
  }));
  res.json({ 
    totalClients: clients.length,
    clients 
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 WebSocket Server running on port ${PORT}`);
  console.log(`📡 Stream status: ${streamState.status}`);
});

module.exports = { app, server, io };