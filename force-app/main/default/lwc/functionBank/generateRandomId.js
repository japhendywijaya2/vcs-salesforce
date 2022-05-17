const arrId = []

function generateRandomId(){
    let randomId = Math.random()
    while(arrId.includes(randomId)){
        randomId = Math.random()
    }
    arrId.push(randomId)
    
    return randomId
}


export default generateRandomId