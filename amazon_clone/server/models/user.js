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
       minlength: 6,
       maxlength: 200, 
      //  validate: {
      //    validator: (value) => {
      //      // Password phải có ít nhất 1 chữ hoa, 1 chữ thường, 1 số, 1 ký tự đặc biệt và không có khoảng trắng
      //      const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])(?!.*\s)[A-Za-z\d@$!%*?&]+$/;
      //      return passwordRegex.test(value);
      //    },
      //    message: "Password must contain at least one lowercase letter, one uppercase letter, one number, one special character, and no spaces",
      //  },
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