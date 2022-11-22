// Importamos primer dataset

const contents = [
    {
        content: "C:\\Users\\USUARIO\\Documents\\MEGA\\Manu\\UCM\\Módulo III. NOSQL\\csvjson.json",
        collection: "acvil",
        idPolicy: "overwrite_with_same_id", //overwrite_with_same_id|always_insert_with_new_id|insert_with_new_id_if_id_exists|skip_documents_with_existing_id|abort_if_id_already_exists|drop_collection_first|log_errors
        //Use the transformer to customize the import result
        //transformer: (doc)=>{ //async (doc)=>{
        //   doc["importDate"]= new Date()
        //   return doc; //return null skips this doc
        //}
    }
];

mb.importContent({
    connection: "localhost",
    database: "gente",
    fromType: "file",
    batchSize: 2000,
    contents
})

// cargamos dataset

db.acvil.find()


// eliminamos campos

db.acvil.updateMany({}, { $unset: { "Filename": "", "Unique Entry ID": "" } })

db.acvil.find({}, { "Name": 1, "Filename": 1, "Hobby": 1, "Unique Entry ID": 1, "_id": 0 })

// creamos dos array basados en dos campos cada uno

db.acvil.update(
    {},
    [{
        $set: {
            Color: ["$Color 1", "$Color 2"],
            Style: ["$Style 1", "$Style 2"]
        }
    }],
    { multi: true })

// eliminamos los campos originales

db.acvil.updateMany({}, { $unset: { "Color 1": "", "Color 2": "", "Style 1": "", "Style 2": "" } })

db.acvil.find()

// contamos los duplicados

db.acvil.aggregate([
    { "$project": { "Style": 1 } },
    { "$unwind": "$Style" },
    { "$group": { "_id": { "_id": "$_id", "Style": "$Style" }, "count": { "$sum": 1 } } },
    { "$match": { "count": { "$gt": 1 } } },
    { "$group": { "_id": "$_id._id", "Style": { "$addToSet": "$_id.Style" } } },
    { "$group": { "_id": null, count: { $sum: 1 } } }
])

db.acvil.aggregate([
    { "$project": { "Color": 1 } },
    { "$unwind": "$Color" },
    { "$group": { "_id": { "_id": "$_id", "Color": "$Color" }, "count": { "$sum": 1 } } },
    { "$match": { "count": { "$gt": 1 } } },
    { "$group": { "_id": "$_id._id", "Color": { "$addToSet": "$_id.Color" } } },
    { "$group": { "_id": null, count: { $sum: 1 } } }
])


// creamos función para eliminar duplicados

function unique(arr) {
    var hash = {}, result = [];
    for (var i = 0, l = arr.length; i < l; ++i) {
        if (!hash.hasOwnProperty(arr[i])) {
            hash[arr[i]] = true;
            result.push(arr[i]);
        }
    }
    return result;
}

// aplicamos función a los arrays 

db.acvil.find({}).forEach(function(doc) {
    db.acvil.update({ _id: doc._id }, { $set: { "Style": unique(doc.Style), "Color": unique(doc.Color) } });
})

db.acvil.find()

// ya no hay duplicados

db.acvil.count({ "Style": { $size: 1 } })

db.acvil.count({ "Color": { $size: 1 } })

// ver qué es más popular

db.acvil.aggregate([
    { "$project": { "Style": 1 } },
    { "$unwind": "$Style" },
    { "$group": { "_id": "$Style", "conteo": { $sum: 1 } } },
    { $sort: { conteo: -1 } }
])

// ver dónde mola más el rosa

db.acvil.aggregate([
    { "$project": { "Color": 1, "Style": 1 } },
    { "$unwind": "$Color" },
    { "$unwind": "$Style" },
    { $match: { "Color": { $eq: "Pink" } } },
    { "$group": { "_id": "$Style", "conteo_rosa": { $sum: 1 } } },
    { $sort: { conteo_rosa: -1 } }
])

// ver la relación entre el negro y el rosa en cada estilo

db.acvil.aggregate([
    { $project: { "Style": 1, "Color": 1 } },
    { $unwind: "$Color" },
    { $unwind: "$Style" },
    {
        $group: {
            "_id": "$Style",
            conteo_negro:
            {
                $sum:
                {
                    $cond: [
                        { $eq: ["$Color", "Black"] }, 1, 0]
                }
            },
            conteo_rosa:
            {
                $sum:
                {
                    $cond: [
                        { $eq: ["$Color", "Pink"] }, 1, 0]
                }
            }
        }
    },
    { $project: { "_id": 1, "ratio": { $divide: ["$conteo_rosa", "$conteo_negro"] } } },
    { $sort: { ratio: -1 } }])


// hacer split y crear array de muebles  

db.acvil.updateMany({},
    [
        {
            $set: {
                Furniture_array: {
                    $filter: {
                        input: { $split: ["$Furniture List", ";"] },
                        cond: { $gt: [{ $strLenCP: "$$this" }, 0] }
                    }
                }
            }
        }
    ])

// Eliminar campo anterior para quedarnos solo con el nuevo array

db.acvil.updateMany({}, { $unset: { "Furniture List": " " } })

db.acvil.find()

// importar dataset con información de muebles

const contents = [
    {
        content: "C:\\Users\\USUARIO\\Documents\\MEGA\\Manu\\UCM\\Módulo III. NOSQL\\housewares.json",
        collection: "housewares",
        idPolicy: "overwrite_with_same_id", //overwrite_with_same_id|always_insert_with_new_id|insert_with_new_id_if_id_exists|skip_documents_with_existing_id|abort_if_id_already_exists|drop_collection_first|log_errors
        //Use the transformer to customize the import result
        //transformer: (doc)=>{ //async (doc)=>{
        //   doc["importDate"]= new Date()
        //   return doc; //return null skips this doc
        //}
    }
];

mb.importContent({
    connection: "localhost",
    database: "gente",
    fromType: "file",
    batchSize: 2000,
    contents
})

db.housewares.find()

// Actualizar dataset de muebles creando un nuevo campo con los IDs como Strings

db.housewares.updateMany({}, [
    {
        $set: {
            IDs: { $toString: "$Internal ID" }
        }
    }])

db.housewares.find()


// Creamos colección nueva haciendo un join

db.getSiblingDB("gente").acvil.aggregate([
    {
        "$lookup": {
            "from": "housewares",
            "localField": "Furniture_array",
            "foreignField": "IDs",
            pipeline: [
                { $project: { _id: 0, "name": "$Name", "id": "$IDs", "precio": "$Sell" } }],
            "as": "Furniture_info"
        }
    },
    { $unwind: "$Furniture_info" },
    {
        $group: {
            _id: "$Name",
            Furniture_info: { $addToSet: "$Furniture_info" },
            Species: { $first: "$Species" },
            Personality: { $first: "$Personality" },
            Hobby: { $first: "$Hobby" },
            Color: { $first: "$Color" },
            Style: { $first: "$Style" },
            Birthday: { $first: "$Birthday" },
            Catchphrase: { $first: "$Catchphrase" },
            "Favorite Song": { $first: "$Favorite Song" },
            Wallpaper: { $first: "$Wallpaper" },
            Flooring: { $first: "$Flooring" },
            Gender: { $first: "$Gender" }
        }
    },
    { $out: "acvil_1" }
])

db.acvil_1.find()

// Contamos los muebles más frecuentes y visualizamos su precio

db.acvil_1.aggregate([
    { $unwind: "$Furniture_info" },
    {
        $group: {
            _id: "$Furniture_info.name",
            precio: { $first: "$Furniture_info.precio" },
            count: { $sum: 1 }
        }
    },
    { $sort: { count: -1 } }
    { $limit: 10 }
])

// Vemos los cinco vecinos más ricos

db.acvil_1.aggregate([
    { $unwind: "$Furniture_info" },
    {
        $group: {
            _id: "$_id", patrimonio: { $sum: "$Furniture_info.precio" },
            muebles: { $push: "$Furniture_info.name" },
            Animal: { $first: "$Species" }
        }
    },
    { $sort: { "patrimonio": -1 } },
    { $limit: 5 }
])

// calculamos diferencia entre ricos y pobres

db.acvil_1.aggregate([
    { $unwind: "$Furniture_info" },
    {
        $group: {
            _id: "$_id", patrimonio: { $sum: "$Furniture_info.precio" },
            nombres: { $push: "$Furniture_info.name" }
        }
    },
    {
        $group: {
            _id: null, pobre: { $max: "$patrimonio" },
            rico: { $min: "$patrimonio" }
        }
    },
    {
        $project: {
            "diferencia_absoluta": { $subtract: ["$pobre", "$rico"] },
            "diferencia_relativa": { $divide: ["$pobre", "$rico"] }
        }
    }
])

//

db.acvil_1.find()


// separamos mes del día

db.acvil_1.updateMany({}, [
    {
        $addFields: {
            Day: { $arrayElemAt: [{ "$split": ["$Birthday", "-"] }, 0] },
            Month: { $arrayElemAt: [{ "$split": ["$Birthday", "-"] }, 1] }
        }
    }
])


db.acvil_1.find()

// Convertirmos el string del mes en un nuevo string con el número

db.acvil_1.updateMany({}, [
    {
        $set: {
            "month": {
                "$switch": {
                    "branches": [
                        { "case": { "$eq": ["$Month", "Jan"] }, "then": "01" },
                        { "case": { "$eq": ["$Month", "Feb"] }, "then": "02" },
                        { "case": { "$eq": ["$Month", "Mar"] }, "then": "03" },
                        { "case": { "$eq": ["$Month", "Apr"] }, "then": "04" },
                        { "case": { "$eq": ["$Month", "May"] }, "then": "05" },
                        { "case": { "$eq": ["$Month", "Jun"] }, "then": "06" },
                        { "case": { "$eq": ["$Month", "Jul"] }, "then": "07" },
                        { "case": { "$eq": ["$Month", "Aug"] }, "then": "08" },
                        { "case": { "$eq": ["$Month", "Sep"] }, "then": "09" },
                        { "case": { "$eq": ["$Month", "Oct"] }, "then": "10" },
                        { "case": { "$eq": ["$Month", "Nov"] }, "then": "11" },
                        { "case": { "$eq": ["$Month", "Dec"] }, "then": "12" }
                    ]
                }
            }
        }
    }
])

// introducimos la variable año

db.acvil_1.updateMany({}, { $set: { "year": "2001" } })

// creamos el string de la fecha y convertimos el string a Date

db.acvil_1.updateMany({}, [{
    $set: {
        "Cumple":
            { $concat: ["$year", "-", "$month", "-" "$Day"] }
        {
    $addFields: {
        cumple: { $toDate: "$Cumple" }
    }
}])


// eliminamos campos

db.acvil_1.updateMany({}, {
    $unset: {
        "Month": "", "Day": "", "month": "", "day": "",
        "year": "", "Birthday": "", "Cumple": ""
    }
})

db.acvil_1.find()

// buscamos quiénes y cuándo comparten cumpleaños

db.acvil_1.aggregate([
    { "$group": { "_id": "$cumple", "vecinos": { $push: "$_id" }, "animal": { $push: "$Species" } "conteo": { $sum: 1 } } },
    {
        $match: {
            "conteo": { $gt: 1 }
        }
    },
    { "$project": { _id: 0, "cumple": "$_id", "vecinos": 1, "animal": 1 } },
    { $sort: { conteo: -1 } }
])

// ahora con muestreo aleatorio

db.acvil_1.aggregate([
    { $sample: { size: 30 } }
    { "$group": { "_id": "$cumple", "vecinos": { $push: "$_id" }, "animal": { $push: "$Species" } "conteo": { $sum: 1 } } },
    {
        $match: {
            "conteo": { $gt: 1 }
        }
    },
    { "$project": { _id: 0, "cumple": "$_id", "vecinos": 1, "animal": 1 } },
    { $sort: { conteo: -1 } }
])

// match con mi cumpleaños

db.acvil_1.aggregate([
    {
        $addFields: {
            fecha: { $toDate: "2001-05-13" }
        }
    },
    { $match: { $expr: { $eq: ["$cumple", "$fecha"] } } },
    { $project: { _id: 1, cumple: 1, Species: 1 } }
])

db.acvil.aggregate([
    { $group: { _id: "$Gender", conteo: { $sum: 1 } } }
])
