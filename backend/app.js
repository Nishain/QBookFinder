const cors = require('cors')
const express = require('express')
const mongoose = require('mongoose')

const app = express()
app.use(cors())
app.use(express.json())
require('dotenv').config()
app.use('/books/',require('./routes/books'))
app.use('/bookStore/',require('./routes/bookStore'))
mongoose.connect(`mongodb+srv://Nishain:${process.env.DB_PASS}@cluster0.0zczl.mongodb.net/QbookFinder?retryWrites=true&w=majority`).then(()=>{
    console.log('connected to database')
})
app.listen(process.env.PORT,()=>{
    console.log("server started on port "+process.env.PORT)
})