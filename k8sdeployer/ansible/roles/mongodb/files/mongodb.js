db.createCollection("test_db")
doc={'a':0, 'item':9}
db.test_db.insertOne(doc)
doc={'a':1, 'item':99}
db.test_db.insertOne(doc)
db.test_db.find();
