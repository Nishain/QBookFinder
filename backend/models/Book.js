const mongoose = require('mongoose')
const schema = mongoose.Schema({
    name:String,
    author:String,
    ISBN:String,
})
schema.index({name:'text'})
module.exports = mongoose.model("Book",schema)