var db = db.getSiblingDB('admin');
db.dropAllUsers({w: "majority", wtimeout: 5000});
db.createUser(
  {
    user: "MongoAdminUser",
    pwd: "password",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
);

db.createUser(
    {
      user: "sageunitymongouser",
      pwd: "URuWCpF8nSkwLkh3",
      roles: [
         { role: "dbOwner", db: "local_analytics" },
         { role: "dbOwner", db: "local_tracking_live" },
         { role: "dbOwner", db: "local_tracking_history" },
         { role: "dbOwner", db: "local_tracking_contact" }
      ]
    }
);

db = db.getSiblingDB('local_analytics');
db.dropAllUsers({w: "majority", wtimeout: 5000});
db.createUser(
    {
      user: "sageunitymongouser",
      pwd: "URuWCpF8nSkwLkh3",
      roles: [
         { role: "dbOwner", db: "local_analytics" }
      ]
    }
);

db = db.getSiblingDB('local_tracking_live');
db.dropAllUsers({w: "majority", wtimeout: 5000});
db.createUser(
    {
      user: "sageunitymongouser",
      pwd: "URuWCpF8nSkwLkh3",
      roles: [
         { role: "dbOwner", db: "local_tracking_live"}
      ]
    }
);

db = db.getSiblingDB('local_tracking_history');
db.dropAllUsers({w: "majority", wtimeout: 5000});
db.createUser(
    {
      user: "sageunitymongouser",
      pwd: "URuWCpF8nSkwLkh3",
      roles: [
         { role: "dbOwner", db: "local_tracking_history"}
      ]
    }
);


db = db.getSiblingDB('local_tracking_contact');
db.dropAllUsers({w: "majority", wtimeout: 5000});
db.createUser(
    {
      user: "sageunitymongouser",
      pwd: "URuWCpF8nSkwLkh3",
      roles: [
         { role: "dbOwner", db: "local_tracking_contact"}
      ]
    }
);

print('');
print('List all Users ...');
db = db.getSiblingDB('admin');
var users =  db.system.users.find()
users.forEach(function(item, index) {
		printjson(item);
	});