const mongoose = require("mongoose");

const productSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true,
    },
    description: {
        type: String,
        required: true,
        trim: true,
    },
    images: [
        {
        type: String,
        required: true,
        },
    ],
    quantity: {
        type: Number,
        required: true,
        min: 1,
    },
    price: {
        type: Number,
        required: true,
        min: 1,
    },
    category: {
        type: String,
        required: true,
    },
    // ratings
});

const Product = mongoose.model("Product", productSchema);
module.exports = Product;
    