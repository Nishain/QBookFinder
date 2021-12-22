const mongoose = require('mongoose')
const schema = mongoose.Schema({
    name:String,
    author:String,
    ISBN:{
        type:String,
        unique:true
    },
})
schema.index({name:'text'})
module.exports = mongoose.model("Book",schema)