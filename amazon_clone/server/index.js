const express = require('express');
const authRouter = require('./routes/auth');
const mognoose = require('mongoose');
const adminRouter = require('./routes/admin');
const productRouter = require('./routes/product');
const userRouter = require('./routes/user');

const PORT = 3000;
const app = express();
const DB = "mongodb+srv://yourmongodbuser:yourmongodbpassword@cluster0.6hzwav2.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

app.use(express.json());
app.use(authRouter);
app.use(adminRouter);
app.use(productRouter);
app.use(userRouter);

mognoose
.connect(DB)
.then(() => {
    console.log("Connected to MongoDB");
    })
    .catch((e) => { 
    console.error(e);
}); 

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Connected to port ${PORT}`);
}); 