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
         // Email phải có định dạng hợp lệ
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
      // Password phải có ít nhất 8 ký tự và chứa ít nhất 3 trong 4 yêu cầu sau:
      // 1 chữ hoa, 1 chữ thường, 1 số, 1 ký tự đặc biệt
      let score = 0;
      
      if (/[a-z]/.test(value)) score++; // chữ thường
      if (/[A-Z]/.test(value)) score++; // chữ hoa  
      if (/\d/.test(value)) score++;    // số
      if (/[@$!%*?&]/.test(value)) score++; // ký tự đặc biệt
      
      // Không có khoảng trắng và cần ít nhất 3/4 tiêu chí
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
});
const User = mongoose.model("User", userSchema);
module.exports = User;