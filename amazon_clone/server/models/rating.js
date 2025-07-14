const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
    userId: {   
        type: String,
        ref: 'User',
        required: true,
    },  
}); 