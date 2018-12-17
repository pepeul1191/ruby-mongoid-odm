## Boilerplate MongoDB Python

Requisitos de software previamente instalado:

	+ Ruby
  + Bundler

### Descipción

Instalación de dependencias:

    $ bundler install

+ Consultar recursivas a árbol similar a:

  ```
  SELECT * FROM vw_distrito_provincia_departamento WHERE nombre LIKE 'La%' LIMIT 0,10;
  ```

  ```
  db.ubicaciones.aggregate([
    {
      $match:{
        tipo: "distrito"
      }
    },
    {
      $lookup:{
        from: "ubicaciones",
        localField: "provincia_id",
        foreignField: "_id",
        as: "provincia"
      }
    },
    {
      $unwind: {
        path: "$provincia",
        preserveNullAndEmptyArrays: true
      }
    },
    {
      $lookup: {
        from: "ubicaciones",
        localField: "provincia.departamento_id",
        foreignField: "_id",
        as: "departamento",
      }
    },
    {
      $unwind: {
        path: "$departamento",
        preserveNullAndEmptyArrays: true
      }
    },
    {
      $match:{
        "departamento.pais_id": ObjectId("5b90a5b1ef627560f1251e4d"),
        "nombre": /^La/
      }
    },
    { $project: {
        "_id": "$_id",
        "nombre": {
          $concat: [
            "$nombre",
            ", ",
            "$provincia.nombre",
            ", ",
            "$departamento.nombre"
          ]
        },
      }
    },
    {
      $limit: 10
    },
  ])
  ```

Almacenar función

~~~
db.system.js.save(
{
  _id: "buscarDistrito",
  value: function(pais_id, nombre){
    var docs = db.ubicaciones.aggregate([
      {
        $match:{
          tipo: "distrito"
        }
      },
      {
        $lookup:{
          from: "ubicaciones",
          localField: "provincia_id",
          foreignField: "_id",
          as: "provincia"
        }
      },
      {
        $unwind: {
          path: "$provincia",
          preserveNullAndEmptyArrays: true
        }
      },
      {
        $lookup: {
          from: "ubicaciones",
          localField: "provincia.departamento_id",
          foreignField: "_id",
          as: "departamento",
        }
      },
      {
        $unwind: {
          path: "$departamento",
          preserveNullAndEmptyArrays: true
        }
      },
      {
        $match:{
          "departamento.pais_id": ObjectId(pais_id),
          "nombre": nombre
        }
      },
      { $project: {
          "_id": "$_id",
          "nombre": {
            $concat: [
              "$nombre",
              ", ",
              "$provincia.nombre",
              ", ",
              "$departamento.nombre"
            ]
          },
        }
      },
      {
        $limit: 10
      },
    ])
    return docs._batch;
  }
});
~~~

Llamar funcion

~~~
db.eval('buscarDistrito("5b90a5b1ef627560f1251e4d","La Victoria")');
~~~

### Comandos backup de MongoDB

    $ mongodump --db ubicaciones --host localhost --port 27017 --out db

### Comandos restore de MongoDB

    $ mongorestore --db ubicaciones --host localhost --port 27017 db/ubicaciones

```

### Fuentes

+ https://stackoverflow.com/questions/11022010/finding-all-documents-in-a-collection-with-mongoid
+ https://docs.mongodb.com/mongoid/master/tutorials/mongoid-installation/
+ https://docs.mongodb.com/mongoid/master/tutorials/mongoid-documents/

Thanks/Credits

    Pepe Valdivia: developer Software Web Perú [http://softweb.pe]
