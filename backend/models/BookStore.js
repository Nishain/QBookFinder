const mongoose = require('mongoose')
const schema = mongoose.Schema({
    name:String,
    shopOwner:String,
    books:{
        type : [String],
        default : []
    },
    location:[Number]
})
schema.index({name:'text'})
schema.index({location:'2dsphere'})
module.exports = mongoose.model("BookStore",schema)