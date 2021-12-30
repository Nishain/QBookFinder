const mongoose = require('mongoose')
module.exports = {
    validate : (params,res)=>{
        const messages = []
        for(const key in params){
            if(params[key] == null || params[key] == '')
                messages.push('should enter value for '+key)
        }
        if(messages.length > 0){
            res.send({validateError:true , message:messages.join('.')})
            return true
        }else
            return false
    },
    validateAgainstSchema : (model,values,res,ignoreEmpty=false)=>{
        const paths = model.schema.paths
        const messages = []
        var fields = [];
        for(const path in paths){
            if(path.startsWith('_'))
                continue
            const expectedTypeName = paths[path].instance.toLowerCase()
            if(!values[path] || values[path] == ''){
                if(!ignoreEmpty && (!paths[path].defaultValue)){
                    messages.push('should enter value for '+path)
                    fields.push(path)
                }
            }
            else if((typeof values[path] != expectedTypeName) && !(expectedTypeName == 'array' && Array.isArray(values[path]))){
                messages.push('should enter valid value for '+path)
                fields.push(path)
            }
        }if(messages.length > 0){
            res.send({validateError:true , message:messages.join('.'),errorFields:fields})
            return true
        }else
            return false
    },
    copyFromBody(values,fieldProperties){
        const submitingFields = {}
        const consideringFields = Object.keys(fieldProperties)
        for(const field in values){
            if(consideringFields.includes(field)){
                if(fieldProperties[field].restrict)
                    continue
                if(fieldProperties[field].lockSingle){
                    submitingFields[field] = values[field][0]
                }
            }else{
                if(values[field] == '')
                    continue
                submitingFields[field] = values[field]  
            }
        }
        return submitingFields
    }
}