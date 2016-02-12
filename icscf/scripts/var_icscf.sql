-- MySQL dump 10.9
--
-- Host: localhost    Database: icscf
-- ------------------------------------------------------
-- Server version	4.1.20-log

--
-- Current Database: `icscf`
--

/*!40000 DROP DATABASE IF EXISTS `icscf`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `icscf` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `icscf`;

--
-- Table structure for table `nds_trusted_domains`
--

DROP TABLE IF EXISTS `nds_trusted_domains`;
CREATE TABLE `nds_trusted_domains` (
  `id` int(11) NOT NULL auto_increment,
  `trusted_domain` varchar(83) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `s_cscf`
--

DROP TABLE IF EXISTS `s_cscf`;
CREATE TABLE `s_cscf` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(83) NOT NULL default '',
  `s_cscf_uri` varchar(83) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `s_cscf_capabilities`
--

DROP TABLE IF EXISTS `s_cscf_capabilities`;
CREATE TABLE `s_cscf_capabilities` (
  `id` int(11) NOT NULL auto_increment,
  `id_s_cscf` int(11) NOT NULL default '0',
  `capability` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `idx_capability` (`capability`),
  KEY `idx_id_s_cscf` (`id_s_cscf`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `icscf` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `icscf`;

--
-- Dumping data for table `nds_trusted_domains`
--


/*!40000 ALTER TABLE `nds_trusted_domains` DISABLE KEYS */;
LOCK TABLES `nds_trusted_domains` WRITE;
INSERT INTO `nds_trusted_domains` VALUES (1,'VAR_DNS_REALM');
UNLOCK TABLES;
/*!40000 ALTER TABLE `nds_trusted_domains` ENABLE KEYS */;

--
-- Dumping data for table `s_cscf`
--


/*!40000 ALTER TABLE `s_cscf` DISABLE KEYS */;
LOCK TABLES `s_cscf` WRITE;
INSERT INTO `s_cscf` VALUES (1,'First and only S-CSCF','sip:VAR_SCSCF_NAME.VAR_DNS_REALM:VAR_SCSCF_PORT');
UNLOCK TABLES;
/*!40000 ALTER TABLE `s_cscf` ENABLE KEYS */;

--
-- Dumping data for table `s_cscf_capabilities`
--


/*!40000 ALTER TABLE `s_cscf_capabilities` DISABLE KEYS */;
LOCK TABLES `s_cscf_capabilities` WRITE;
INSERT INTO `s_cscf_capabilities` VALUES (1,1,0),(2,1,1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `s_cscf_capabilities` ENABLE KEYS */;

-- DB access rights
-- grant delete,insert,select,update on icscf.* to icscf@localhost identified by 'heslo';
-- grant delete,insert,select,update on icscf.* to provisioning@localhost identified by 'provi';
