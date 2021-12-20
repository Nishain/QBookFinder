const mongoose = require('mongoose')
const schema = mongoose.Schema({
    name:String,
    shopOwner:String,
    books:{
        type : [String],
        default : []
    }
})
schema.index({name:'text'})
module.exports = mongoose.model("BookStore",schema)