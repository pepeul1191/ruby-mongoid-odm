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

+ http://mongomapper.com/documentation/getting-started/sinatra.html
+ https://gist.github.com/chischaschos/793861
+ https://github.com/pepeul1191/ruby-ulima-visitas-back
+ https://github.com/mongomapper/mongomapper/issues/230
+ https://speakerdeck.com/jnunemaker/mongomapper-mapping-ruby-to-and-from-mongo?slide=58
+ https://stackoverflow.com/questions/6240738/edit-mongomapper-document
+ https://stackoverflow.com/questions/9531900/setting-up-mongomapper-for-multiple-databases

Thanks/Credits

    Pepe Valdivia: developer Software Web Perú [http://softweb.pe]
