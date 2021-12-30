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
    
    await new Book(req.body).save().then(result=>res.send(result))
    .catch(error=>{
        if(error.code == 11000 && error.keyValue && error.keyValue.ISBN)
            res.send({duplicateError:true,message:"Book already exist"})
        else
            throw error
    })
})
router.put('/:isbn',async (req,res)=>{
    const isbn = req.params.isbn
    const foundBook = await Book.findOne({ISBN:isbn})
    if(!foundBook)
        return res.send({notFound:true,message:"book not found"})
    commonUtils.validateAgainstSchema(Book,req.body,res,true)    
    foundBook.set(req.body).save().then(result=>res.send(result))
    .catch(error=>{
        if(error.code == 11000 && error.keyValue && error.keyValue.ISBN)
            res.send({duplicateError:true,message:"ISBN is should be unique"})
        else
            throw error
    })
})
router.delete('/:isbn',async (req,res)=>{
    const isbn = req.params.isbn
    const foundBook = await Book.findOne({ISBN:isbn})
    if(!foundBook)
        return res.send({notFound:true,message:"book not found"})
    const deleteResult = await Book.deleteOne({ISBN:isbn})    
    res.send({deleteCount:deleteResult.deletedCount})
})
module.exports = router

