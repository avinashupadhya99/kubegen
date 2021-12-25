var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  const keywords = ["Affinity", "Annotation", "API Group", "API server", "Applications", "cgroup", "Cluster", "Container"];
  const keyword = keywords[Math.floor(Math.random()*keywords.length)];
  res.send({keyword});
});

module.exports = router;
