const express = require('express');
const User = require('../models/user');
const bcrypt = require('bcryptjs');
const authRouter = express.Router();


// POST /api/signUp
authRouter.post("/api/signUp", async (req, res) => {
    try {
    const { name, email, password } = req.body; 

    const existingUser = await User.findOne({ email });
    if (existingUser) {
        return res
        .status(400)
        .json({ msg: "Email already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 8);
    
    let user = new User({  
        email,
        password: hashedPassword,
        name, 
    });
    user = await user.save();
    res.json(user);   
    } catch (e) {
        res.status(500).json({ error: e.message });
    }   
});

module.exports = authRouter;