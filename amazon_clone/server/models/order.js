const mongoose = require('mongoose');
const { productSchema } = require('./product');

const orderSchema = new mongoose.Schema({
products: [
    {
      product: productSchema,
      quantity: {
        type: Number,
        required: true,
      },
    },
  ],
  totalPrice: {
    type: Number,
    required: true,
  },
  address: {
    type: String,
    required: true,
  },
  userId: {
    required: true,
    type: String,
  },
  orderedAt: {
    type: Number,
    required: true,
  },
  status: {
    type: Number,
    default: 0,
  },
  paymentMethod: {
    type: String,
    enum: ['Online', 'COD'],
    default: 'Online',
  },
});

const Order = mongoose.model('Order', orderSchema);
module.exports = Order;