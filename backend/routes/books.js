const router = require('express').Router()
const commonUtils = require('../common');
const Book = require('../models/Book')

router.get('/',async (req,res)=>{
    const bookName = req.body.name;
    if(commonUtils.validate({'Book Name':bookName}))
        return
    const bookList = await Book.find({$text:{$search:bookName}})
    return res.send({list:bookList})
})
router.post('/',async (req,res)=>{
    if(commonUtils.validateAgainstSchema(Book,req.body,res))
        return
    const newBook = await new Book(req.body).save()  
    return  res.send(newBook)
})
router.put('/:isbn',async (req,res)=>{
    const isbn = req.params.isbn
    const foundBook = await Book.findOne({ISBN:isbn})
    if(!foundBook)
        return res.status(404).send({message:"book not found"})
    commonUtils.validateAgainstSchema(Book,req.body,res,true)    
    const updatedBook = await foundBook.set(req.body).save()
    res.send(updatedBook)
})
router.delete('/:isbn',async (req,res)=>{
    const isbn = req.params.isbn
    const foundBook = await Book.findOne({ISBN:isbn})
    if(!foundBook)
        return res.status(404).send({message:"book not found"})
    const deleteResult = await Book.deleteOne({ISBN:isbn})    
    res.send({deleteCount:deleteResult.deletedCount})
})
module.exports = router

