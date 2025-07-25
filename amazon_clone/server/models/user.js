const mongoose = require('mongoose');
const { productSchema } = require('./product');

const userSchema = new mongoose.Schema({
    name: {
        required: true,
        type: String,
        trim: true,
    },
    email: {
        required: true,
        type: String,
        trim: true,
        validate: {
        validator: (value) => {
         // Email must have a valid format
        const re =
          /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
        return value.match(re);
      },
      message: "Please enter a valid email address",
    },
    },
    password: {
      required: true,
      type: String,
      minlength: 8,
      maxlength: 128, 
      validate: {
      validator: (value) => {
      // Password must have at least 8 characters and contain at least 3 of the following 4 requirements:
      // 1 uppercase, 1 lowercase, 1 number, 1 special character
      let score = 0;
      
      if (/[a-z]/.test(value)) score++; // lowercase
      if (/[A-Z]/.test(value)) score++; // uppercase
      if (/\d/.test(value)) score++;    // number
      if (/[@$!%*?&]/.test(value)) score++; // special character
      
      // No spaces and needs at least 3/4 criteria
      return !/\s/.test(value) && score >= 3;
     },
      message: "Password must be 8+ characters with at least 3 of: uppercase, lowercase, number, special character (@$!%*?&), and no spaces",
   },
    },
    address: {
       type: String,
       default: "",
    },
    type: {
       type: String,
       default: "user",
    },
    cart: [
      {
         product: productSchema,
         quantity: {
            type: Number,
            required: true,
         },
      }
    ],
    wishlist: [
      {
         type: mongoose.Schema.Types.ObjectId,
         ref: 'Product',
      }
    ],
    phone: {
       type: String,
       default: "",
    },
    avatar: {
       type: String,
       default: "",
    },
});
const User = mongoose.model("User", userSchema);
module.exports = User;