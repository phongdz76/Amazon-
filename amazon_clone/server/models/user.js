const express = require('express');
const mongoose = require('mongoose');

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
       maxlength: 80,
    },
    address: {
       type: String,
       default: "",
    },
    type: {
       type: String,
       default: "user",
    },
});
const User = mongoose.model("User", userSchema);
module.exports = User;