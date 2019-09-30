DROP DATABASE IF EXISTS ds3;

CREATE DATABASE ds3;

USE ds3;

# drop table tb_sns_index_analysis;

CREATE TABLE tb_sns_index_analysis(
	register_date VARCHAR(8) PRIMARY KEY,
	sns_type VARCHAR(1) NOT NULL,
	positive_count INT(10) NOT NULL,
	negative_count INT(10) NOT NULL,
	neutral_count INT(10) NOT NULL
);


# drop monthly_table tb_sns_index_analysis;

CREATE TABLE monthly_tb_sns_index_analysis(
	register_date VARCHAR(8) PRIMARY KEY,
	sns_type VARCHAR(1) NOT NULL,
	positive_count INT(10) NOT NULL,
	negative_count INT(10) NOT NULL,
	neutral_count INT(10) NOT NULL
);

	
DESC tb_sns_index_analysis;

INSERT INTO tb_sns_index_analysis
(sns_type,register_date,positive_count,negative_count,neutral_count)
VALUE ("20200101","B",1,1,1),("20200905","B",1,1,1)

# truncate tb_sns_index_analysis;

SELECT *
FROM tb_sns_index_analysis;

SELECT *
FROM monthly_tb_sns_index_analysis;

SELECT register_date, sns_type, SUM(positive_count) AS positive_count, SUM(negative_count) AS negative_count, SUM(neutral_count) AS neutral_count
FROM monthly_tb_sns_index_analysis
GROUP BY sns_type
