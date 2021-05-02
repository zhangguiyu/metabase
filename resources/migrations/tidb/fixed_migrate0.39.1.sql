--  *********************************************************************
--  Update Database Script
--  *********************************************************************
--  Change Log: liquibase.yaml
--  Ran at: 4/30/21, 8:26 AM
--  Against: metabase_root@jdbc:mysql://a88f4db18dc784974969e30b4138360f-7cc94653d9ba60fc.elb.ap-southeast-1.amazonaws.com:4000/metabase_dev
--  Liquibase version: 3.6.3
--  *********************************************************************

USE metabase_dev;

--  Lock Database
UPDATE metabase_dev.DATABASECHANGELOGLOCK SET `LOCKED` = 1, LOCKEDBY = '68a21122914e (172.17.0.2)', LOCKGRANTED = '2021-04-30 13:33:48.852' WHERE ID = 1 AND `LOCKED` = 0;



--  Changeset migrations/000_migrations.yaml::1::agilliland
CREATE TABLE `metabase_dev`.`core_organization` (`id` INT AUTO_INCREMENT NOT NULL, `slug` VARCHAR(254) NOT NULL, `name` VARCHAR(254) NOT NULL, `description` TEXT NULL, `logo_url` VARCHAR(254) NULL, `inherits` BIT(1) NOT NULL, CONSTRAINT `PK_CORE_ORGANIZATION` PRIMARY KEY (`id`), UNIQUE (`slug`)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE `metabase_dev`.`core_user` (`id` INT AUTO_INCREMENT NOT NULL, `email` VARCHAR(254) NOT NULL, `first_name` VARCHAR(254) NOT NULL, `last_name` VARCHAR(254) NOT NULL, `password` VARCHAR(254) NOT NULL, `password_salt` VARCHAR(254) DEFAULT 'default' NOT NULL, `date_joined` datetime NOT NULL, `last_login` datetime NULL, `is_staff` BIT(1) NOT NULL, `is_superuser` BIT(1) NOT NULL, `is_active` BIT(1) NOT NULL, `reset_token` VARCHAR(254) NULL, `reset_triggered` BIGINT NULL, CONSTRAINT `PK_CORE_USER` PRIMARY KEY (`id`), UNIQUE (`email`)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE `metabase_dev`.`core_userorgperm` (`id` INT AUTO_INCREMENT NOT NULL, `admin` BIT(1) NOT NULL, `user_id` INT NOT NULL, `organization_id` INT NOT NULL, CONSTRAINT `PK_CORE_USERORGPERM` PRIMARY KEY (`id`), CONSTRAINT `fk_userorgperm_ref_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `metabase_dev`.core_organization(id), CONSTRAINT `fk_userorgperm_ref_user_id` FOREIGN KEY (`user_id`) REFERENCES `metabase_dev`.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `metabase_dev`.`core_userorgperm` ADD CONSTRAINT `idx_unique_user_id_organization_id` UNIQUE (`user_id`, `organization_id`);

CREATE INDEX `idx_userorgperm_user_id` ON `metabase_dev`.`core_userorgperm`(`user_id`);

CREATE INDEX `idx_userorgperm_organization_id` ON `metabase_dev`.`core_userorgperm`(`organization_id`);

CREATE TABLE `metabase_dev`.`core_permissionsviolation` (`id` INT AUTO_INCREMENT NOT NULL, `url` VARCHAR(254) NOT NULL, `timestamp` datetime NOT NULL, `user_id` INT NOT NULL, CONSTRAINT `PK_CORE_PERMISSIONSVIOLATION` PRIMARY KEY (`id`), CONSTRAINT `fk_permissionviolation_ref_user_id` FOREIGN KEY (`user_id`) REFERENCES `metabase_dev`.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_permissionsviolation_user_id` ON `metabase_dev`.`core_permissionsviolation`(`user_id`);

CREATE TABLE `metabase_dev`.`metabase_database` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `name` VARCHAR(254) NOT NULL, `description` TEXT NULL, `organization_id` INT NOT NULL, `details` TEXT NULL, `engine` VARCHAR(254) NOT NULL, CONSTRAINT `PK_METABASE_DATABASE` PRIMARY KEY (`id`), CONSTRAINT `fk_database_ref_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `metabase_dev`.core_organization(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_database_organization_id` ON `metabase_dev`.`metabase_database`(`organization_id`);

CREATE TABLE `metabase_dev`.`metabase_table` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `name` VARCHAR(254) NOT NULL, `rows` INT NULL, `description` TEXT NULL, `entity_name` VARCHAR(254) NULL, `entity_type` VARCHAR(254) NULL, `active` BIT(1) NOT NULL, `db_id` INT NOT NULL, CONSTRAINT `PK_METABASE_TABLE` PRIMARY KEY (`id`), CONSTRAINT `fk_table_ref_database_id` FOREIGN KEY (`db_id`) REFERENCES `metabase_dev`.metabase_database(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_table_db_id` ON `metabase_dev`.`metabase_table`(`db_id`);

CREATE TABLE `metabase_dev`.`metabase_field` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `name` VARCHAR(254) NOT NULL, `base_type` VARCHAR(255) NOT NULL, `special_type` VARCHAR(255) NULL, `active` BIT(1) NOT NULL, `description` TEXT NULL, `preview_display` BIT(1) NOT NULL, `position` INT NOT NULL, `table_id` INT NOT NULL, `field_type` VARCHAR(254) NOT NULL, CONSTRAINT `PK_METABASE_FIELD` PRIMARY KEY (`id`), CONSTRAINT `fk_field_ref_table_id` FOREIGN KEY (`table_id`) REFERENCES `metabase_dev`.metabase_table(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_field_table_id` ON `metabase_dev`.`metabase_field`(`table_id`);

CREATE TABLE `metabase_dev`.`metabase_foreignkey` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `relationship` VARCHAR(254) NOT NULL, `destination_id` INT NOT NULL, `origin_id` INT NOT NULL, CONSTRAINT `PK_METABASE_FOREIGNKEY` PRIMARY KEY (`id`), CONSTRAINT `fk_foreignkey_dest_ref_field_id` FOREIGN KEY (`destination_id`) REFERENCES `metabase_dev`.metabase_field(id), CONSTRAINT `fk_foreignkey_origin_ref_field_id` FOREIGN KEY (`origin_id`) REFERENCES `metabase_dev`.metabase_field(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_foreignkey_destination_id` ON `metabase_dev`.`metabase_foreignkey`(`destination_id`);

CREATE INDEX `idx_foreignkey_origin_id` ON `metabase_dev`.`metabase_foreignkey`(`origin_id`);

-- [x] fixed alter timestamp
CREATE TABLE `metabase_dev`.`metabase_fieldvalues` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` timestamp(6) NOT NULL, `values` TEXT NULL, `human_readable_values` TEXT NULL, `field_id` INT NOT NULL, CONSTRAINT `PK_METABASE_FIELDVALUES` PRIMARY KEY (`id`), CONSTRAINT `fk_fieldvalues_ref_field_id` FOREIGN KEY (`field_id`) REFERENCES `metabase_dev`.metabase_field(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_fieldvalues_field_id` ON `metabase_dev`.`metabase_fieldvalues`(`field_id`);

CREATE TABLE `metabase_dev`.`metabase_tablesegment` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `name` VARCHAR(254) NOT NULL, `table_id` INT NOT NULL, `filter_clause` TEXT NOT NULL, CONSTRAINT `PK_METABASE_TABLESEGMENT` PRIMARY KEY (`id`), CONSTRAINT `fk_tablesegment_ref_table_id` FOREIGN KEY (`table_id`) REFERENCES `metabase_dev`.metabase_table(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_tablesegment_table_id` ON `metabase_dev`.`metabase_tablesegment`(`table_id`);

CREATE TABLE `metabase_dev`.`query_query` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `name` VARCHAR(254) NOT NULL, `type` VARCHAR(254) NOT NULL, `details` TEXT NOT NULL, `version` INT NOT NULL, `public_perms` INT NOT NULL, `creator_id` INT NOT NULL, `database_id` INT NOT NULL, CONSTRAINT `PK_QUERY_QUERY` PRIMARY KEY (`id`), CONSTRAINT `fk_query_ref_database_id` FOREIGN KEY (`database_id`) REFERENCES `metabase_dev`.metabase_database(id), CONSTRAINT `fk_query_ref_user_id` FOREIGN KEY (`creator_id`) REFERENCES `metabase_dev`.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_query_creator_id` ON `metabase_dev`.`query_query`(`creator_id`);

CREATE INDEX `idx_query_database_id` ON `metabase_dev`.`query_query`(`database_id`);

-- [x] fixed to avoid 49::camsaul ALTER TABLE metabase_dev.query_queryexecution MODIFY executor_id INT NULL;
CREATE TABLE `metabase_dev`.`query_queryexecution` (`id` INT AUTO_INCREMENT NOT NULL, `uuid` VARCHAR(254) NOT NULL, `version` INT NOT NULL, `json_query` TEXT NOT NULL, `raw_query` TEXT NOT NULL, `status` VARCHAR(254) NOT NULL, `started_at` datetime NOT NULL, `finished_at` datetime NULL, `running_time` INT NOT NULL, `error` TEXT NOT NULL, `result_file` VARCHAR(254) NOT NULL, `result_rows` INT NOT NULL, `result_data` TEXT NOT NULL, `query_id` INT NULL, `additional_info` TEXT NOT NULL, `executor_id` INT NULL, CONSTRAINT `PK_QUERY_QUERYEXECUTION` PRIMARY KEY (`id`), CONSTRAINT `fk_queryexecution_ref_user_id` FOREIGN KEY (`executor_id`) REFERENCES `metabase_dev`.core_user(id), CONSTRAINT `fk_queryexecution_ref_query_id` FOREIGN KEY (`query_id`) REFERENCES `metabase_dev`.query_query(id), UNIQUE (`uuid`)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_queryexecution_query_id` ON `metabase_dev`.`query_queryexecution`(`query_id`);

CREATE INDEX `idx_queryexecution_executor_id` ON `metabase_dev`.`query_queryexecution`(`executor_id`);

CREATE TABLE `metabase_dev`.`report_card` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `name` VARCHAR(254) NOT NULL, `description` TEXT NULL, `display` VARCHAR(254) NOT NULL, `public_perms` INT NOT NULL, `dataset_query` TEXT NOT NULL, `visualization_settings` TEXT NOT NULL, `creator_id` INT NOT NULL, `organization_id` INT NOT NULL, CONSTRAINT `PK_REPORT_CARD` PRIMARY KEY (`id`), CONSTRAINT `fk_card_ref_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `metabase_dev`.core_organization(id), CONSTRAINT `fk_card_ref_user_id` FOREIGN KEY (`creator_id`) REFERENCES `metabase_dev`.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_card_creator_id` ON `metabase_dev`.`report_card`(`creator_id`);

CREATE INDEX `idx_card_organization_id` ON `metabase_dev`.`report_card`(`organization_id`);

CREATE TABLE `metabase_dev`.`report_cardfavorite` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `card_id` INT NOT NULL, `owner_id` INT NOT NULL, CONSTRAINT `PK_REPORT_CARDFAVORITE` PRIMARY KEY (`id`), CONSTRAINT `fk_cardfavorite_ref_card_id` FOREIGN KEY (`card_id`) REFERENCES `metabase_dev`.report_card(id), CONSTRAINT `fk_cardfavorite_ref_user_id` FOREIGN KEY (`owner_id`) REFERENCES `metabase_dev`.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `metabase_dev`.`report_cardfavorite` ADD CONSTRAINT `idx_unique_cardfavorite_card_id_owner_id` UNIQUE (`card_id`, `owner_id`);

CREATE INDEX `idx_cardfavorite_card_id` ON `metabase_dev`.`report_cardfavorite`(`card_id`);

CREATE INDEX `idx_cardfavorite_owner_id` ON `metabase_dev`.`report_cardfavorite`(`owner_id`);

CREATE TABLE `metabase_dev`.`report_dashboard` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `name` VARCHAR(254) NOT NULL, `description` TEXT NULL, `public_perms` INT NOT NULL, `creator_id` INT NOT NULL, `organization_id` INT NOT NULL, CONSTRAINT `PK_REPORT_DASHBOARD` PRIMARY KEY (`id`), CONSTRAINT `fk_dashboard_ref_user_id` FOREIGN KEY (`creator_id`) REFERENCES `metabase_dev`.core_user(id), CONSTRAINT `fk_dashboard_ref_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `metabase_dev`.core_organization(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_dashboard_creator_id` ON `metabase_dev`.`report_dashboard`(`creator_id`);

CREATE INDEX `idx_dashboard_organization_id` ON `metabase_dev`.`report_dashboard`(`organization_id`);

-- [x] fixed card_id set to NULL to fix 71::camsaul error
CREATE TABLE `metabase_dev`.`report_dashboardcard` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `sizeX` INT NOT NULL, `sizeY` INT NOT NULL, `row` INT NULL, `col` INT NULL, `card_id` INT NULL, `dashboard_id` INT NOT NULL, CONSTRAINT `PK_REPORT_DASHBOARDCARD` PRIMARY KEY (`id`), CONSTRAINT `fk_dashboardcard_ref_dashboard_id` FOREIGN KEY (`dashboard_id`) REFERENCES `metabase_dev`.report_dashboard(id), CONSTRAINT `fk_dashboardcard_ref_card_id` FOREIGN KEY (`card_id`) REFERENCES `metabase_dev`.report_card(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_dashboardcard_card_id` ON `metabase_dev`.`report_dashboardcard`(`card_id`);

CREATE INDEX `idx_dashboardcard_dashboard_id` ON `metabase_dev`.`report_dashboardcard`(`dashboard_id`);

CREATE TABLE `metabase_dev`.`report_dashboardsubscription` (`id` INT AUTO_INCREMENT NOT NULL, `dashboard_id` INT NOT NULL, `user_id` INT NOT NULL, CONSTRAINT `PK_REPORT_DASHBOARDSUBSCRIPTION` PRIMARY KEY (`id`), CONSTRAINT `fk_dashboardsubscription_ref_user_id` FOREIGN KEY (`user_id`) REFERENCES `metabase_dev`.core_user(id), CONSTRAINT `fk_dashboardsubscription_ref_dashboard_id` FOREIGN KEY (`dashboard_id`) REFERENCES `metabase_dev`.report_dashboard(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `metabase_dev`.`report_dashboardsubscription` ADD CONSTRAINT `idx_uniq_dashsubscrip_dashboard_id_user_id` UNIQUE (`dashboard_id`, `user_id`);

CREATE INDEX `idx_dashboardsubscription_dashboard_id` ON `metabase_dev`.`report_dashboardsubscription`(`dashboard_id`);

CREATE INDEX `idx_dashboardsubscription_user_id` ON `metabase_dev`.`report_dashboardsubscription`(`user_id`);

CREATE TABLE `metabase_dev`.`report_emailreport` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `name` VARCHAR(254) NOT NULL, `description` TEXT NULL, `public_perms` INT NOT NULL, `mode` INT NOT NULL, `version` INT NOT NULL, `dataset_query` TEXT NOT NULL, `email_addresses` TEXT NULL, `creator_id` INT NOT NULL, `organization_id` INT NOT NULL, `schedule` TEXT NOT NULL, CONSTRAINT `PK_REPORT_EMAILREPORT` PRIMARY KEY (`id`), CONSTRAINT `fk_emailreport_ref_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `metabase_dev`.core_organization(id), CONSTRAINT `fk_emailreport_ref_user_id` FOREIGN KEY (`creator_id`) REFERENCES `metabase_dev`.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_emailreport_creator_id` ON `metabase_dev`.`report_emailreport`(`creator_id`);

CREATE INDEX `idx_emailreport_organization_id` ON `metabase_dev`.`report_emailreport`(`organization_id`);

CREATE TABLE `metabase_dev`.`report_emailreport_recipients` (`id` INT AUTO_INCREMENT NOT NULL, `emailreport_id` INT NOT NULL, `user_id` INT NOT NULL, CONSTRAINT `PK_REPORT_EMAILREPORT_RECIPIENTS` PRIMARY KEY (`id`), CONSTRAINT `fk_emailreport_recipients_ref_emailreport_id` FOREIGN KEY (`emailreport_id`) REFERENCES `metabase_dev`.report_emailreport(id), CONSTRAINT `fk_emailreport_recipients_ref_user_id` FOREIGN KEY (`user_id`) REFERENCES `metabase_dev`.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `metabase_dev`.`report_emailreport_recipients` ADD CONSTRAINT `idx_uniq_emailreportrecip_emailreport_id_user_id` UNIQUE (`emailreport_id`, `user_id`);

CREATE INDEX `idx_emailreport_recipients_emailreport_id` ON `metabase_dev`.`report_emailreport_recipients`(`emailreport_id`);

CREATE INDEX `idx_emailreport_recipients_user_id` ON `metabase_dev`.`report_emailreport_recipients`(`user_id`);

CREATE TABLE `metabase_dev`.`report_emailreportexecutions` (`id` INT AUTO_INCREMENT NOT NULL, `details` TEXT NOT NULL, `status` VARCHAR(254) NOT NULL, `created_at` datetime NOT NULL, `started_at` datetime NULL, `finished_at` datetime NULL, `error` TEXT NOT NULL, `sent_email` TEXT NOT NULL, `organization_id` INT NOT NULL, `report_id` INT NULL, CONSTRAINT `PK_REPORT_EMAILREPORTEXECUTIONS` PRIMARY KEY (`id`), CONSTRAINT `fk_emailreportexecutions_ref_report_id` FOREIGN KEY (`report_id`) REFERENCES `metabase_dev`.report_emailreport(id), CONSTRAINT `fk_emailreportexecutions_ref_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `metabase_dev`.core_organization(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_emailreportexecutions_organization_id` ON `metabase_dev`.`report_emailreportexecutions`(`organization_id`);

CREATE INDEX `idx_emailreportexecutions_report_id` ON `metabase_dev`.`report_emailreportexecutions`(`report_id`);

CREATE TABLE `metabase_dev`.`annotation_annotation` (`id` INT AUTO_INCREMENT NOT NULL, `created_at` datetime NOT NULL, `updated_at` datetime NOT NULL, `start` datetime NOT NULL, `end` datetime NOT NULL, `title` TEXT NULL, `body` TEXT NOT NULL, `annotation_type` INT NOT NULL, `edit_count` INT NOT NULL, `object_type_id` INT NOT NULL, `object_id` INT NOT NULL, `author_id` INT NOT NULL, `organization_id` INT NOT NULL, CONSTRAINT `PK_ANNOTATION_ANNOTATION` PRIMARY KEY (`id`), CONSTRAINT `fk_annotation_ref_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `metabase_dev`.core_organization(id), CONSTRAINT `fk_annotation_ref_user_id` FOREIGN KEY (`author_id`) REFERENCES `metabase_dev`.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX `idx_annotation_author_id` ON `metabase_dev`.`annotation_annotation`(`author_id`);

CREATE INDEX `idx_annotation_organization_id` ON `metabase_dev`.`annotation_annotation`(`organization_id`);

CREATE INDEX `idx_annotation_object_type_id` ON `metabase_dev`.`annotation_annotation`(`object_type_id`);

CREATE INDEX `idx_annotation_object_id` ON `metabase_dev`.`annotation_annotation`(`object_id`);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('1', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 1, '8:29a8f482877466643f65adb20c6d2139', 'createTable tableName=core_organization; createTable tableName=core_user; createTable tableName=core_userorgperm; addUniqueConstraint constraintName=idx_unique_user_id_organization_id, tableName=core_userorgperm; createIndex indexName=idx_userorgp...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::2::agilliland
CREATE TABLE metabase_dev.core_session (id VARCHAR(254) NOT NULL, user_id INT NOT NULL, created_at datetime NOT NULL, CONSTRAINT PK_CORE_SESSION PRIMARY KEY (id), CONSTRAINT fk_session_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('2', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 2, '8:983477ec51adb1236dd9d76ebf604be9', 'createTable tableName=core_session', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::4::cammsaul
CREATE TABLE metabase_dev.setting (`key` VARCHAR(254) NOT NULL, value VARCHAR(254) NOT NULL, CONSTRAINT PK_SETTING PRIMARY KEY (`key`)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('4', 'cammsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 3, '8:a8e7822a91ea122212d376f5c2d4158f', 'createTable tableName=setting', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::5::agilliland
ALTER TABLE metabase_dev.core_organization ADD report_timezone VARCHAR(254) NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('5', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 4, '8:4f8653d16f4b102b3dff647277b6b988', 'addColumn tableName=core_organization', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::6::agilliland
ALTER TABLE metabase_dev.metabase_database DROP FOREIGN KEY fk_database_ref_organization_id;

ALTER TABLE metabase_dev.metabase_database MODIFY organization_id INT NULL;

ALTER TABLE metabase_dev.report_card DROP FOREIGN KEY fk_card_ref_organization_id;

ALTER TABLE metabase_dev.report_card MODIFY organization_id INT NULL;

ALTER TABLE metabase_dev.report_dashboard DROP FOREIGN KEY fk_dashboard_ref_organization_id;

ALTER TABLE metabase_dev.report_dashboard MODIFY organization_id INT NULL;

ALTER TABLE metabase_dev.report_emailreport DROP FOREIGN KEY fk_emailreport_ref_organization_id;

ALTER TABLE metabase_dev.report_emailreport MODIFY organization_id INT NULL;

ALTER TABLE metabase_dev.report_emailreportexecutions DROP FOREIGN KEY fk_emailreportexecutions_ref_organization_id;

ALTER TABLE metabase_dev.report_emailreportexecutions MODIFY organization_id INT NULL;

ALTER TABLE metabase_dev.annotation_annotation DROP FOREIGN KEY fk_annotation_ref_organization_id;

ALTER TABLE metabase_dev.annotation_annotation MODIFY organization_id INT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('6', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 5, '8:57d45682c8ae0a22cfccb1711d7821ce', 'dropForeignKeyConstraint baseTableName=metabase_database, constraintName=fk_database_ref_organization_id; dropNotNullConstraint columnName=organization_id, tableName=metabase_database; dropForeignKeyConstraint baseTableName=report_card, constraint...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::7::cammsaul
ALTER TABLE metabase_dev.metabase_field ADD parent_id INT NULL;

ALTER TABLE metabase_dev.metabase_field ADD CONSTRAINT fk_field_parent_ref_field_id FOREIGN KEY (parent_id) REFERENCES metabase_dev.metabase_field (id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('7', 'cammsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 6, '8:c57c69fd78d804beb77d261066521f7f', 'addColumn tableName=metabase_field', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::8::tlrobinson
ALTER TABLE metabase_dev.metabase_table ADD display_name VARCHAR(254) NULL;

ALTER TABLE metabase_dev.metabase_field ADD display_name VARCHAR(254) NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('8', 'tlrobinson', 'migrations/000_migrations.yaml', current_timestamp(6), 7, '8:960ec59bbcb4c9f3fa8362eca9af4075', 'addColumn tableName=metabase_table; addColumn tableName=metabase_field', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::9::tlrobinson
ALTER TABLE metabase_dev.metabase_table ADD visibility_type VARCHAR(254) NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('9', 'tlrobinson', 'migrations/000_migrations.yaml', current_timestamp(6), 8, '8:d560283a190e3c60802eb04f5532a49d', 'addColumn tableName=metabase_table', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::10::cammsaul
CREATE TABLE metabase_dev.revision (id INT AUTO_INCREMENT NOT NULL, model VARCHAR(16) NOT NULL, model_id INT NOT NULL, user_id INT NOT NULL, timestamp datetime NOT NULL, object TEXT NOT NULL, is_reversion BIT(1) DEFAULT 0 NOT NULL, CONSTRAINT PK_REVISION PRIMARY KEY (id), CONSTRAINT fk_revision_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_revision_model_model_id ON metabase_dev.revision(model, model_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('10', 'cammsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 9, '8:96e54d9100db3f9cdcc00eaeccc200a3', 'createTable tableName=revision; createIndex indexName=idx_revision_model_model_id, tableName=revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::11::agilliland
update report_dashboard set public_perms = 2 where public_perms = 1;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('11', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 10, '8:ca6561cab1eedbcf4dcb6d6e22cd46c6', 'sql', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::12::agilliland
ALTER TABLE metabase_dev.report_card ADD database_id INT NULL;

ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_report_card_ref_database_id FOREIGN KEY (database_id) REFERENCES metabase_dev.metabase_database (id);

ALTER TABLE metabase_dev.report_card ADD table_id INT NULL;

ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_report_card_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase_dev.metabase_table (id);

ALTER TABLE metabase_dev.report_card ADD query_type VARCHAR(16) NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('12', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 11, '8:e862a199cba5b4ce0cba713110f66cfb', 'addColumn tableName=report_card; addColumn tableName=report_card; addColumn tableName=report_card', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::13::agilliland
CREATE TABLE metabase_dev.activity (id INT AUTO_INCREMENT NOT NULL, topic VARCHAR(32) NOT NULL, timestamp datetime NOT NULL, user_id INT NULL, model VARCHAR(16) NULL, model_id INT NULL, database_id INT NULL, table_id INT NULL, custom_id VARCHAR(48) NULL, details TEXT NOT NULL, CONSTRAINT PK_ACTIVITY PRIMARY KEY (id), CONSTRAINT fk_activity_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_activity_timestamp ON metabase_dev.activity(timestamp);

CREATE INDEX idx_activity_user_id ON metabase_dev.activity(user_id);

CREATE INDEX idx_activity_custom_id ON metabase_dev.activity(custom_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('13', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 12, '8:0cbc15990a7e73c8cc1fa5961ec2ba97', 'createTable tableName=activity; createIndex indexName=idx_activity_timestamp, tableName=activity; createIndex indexName=idx_activity_user_id, tableName=activity; createIndex indexName=idx_activity_custom_id, tableName=activity', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::14::agilliland
CREATE TABLE metabase_dev.view_log (id INT AUTO_INCREMENT NOT NULL, user_id INT NULL, model VARCHAR(16) NOT NULL, model_id INT NOT NULL, timestamp datetime NOT NULL, CONSTRAINT PK_VIEW_LOG PRIMARY KEY (id), CONSTRAINT fk_view_log_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_view_log_user_id ON metabase_dev.view_log(user_id);

CREATE INDEX idx_view_log_timestamp ON metabase_dev.view_log(model_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('14', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 13, '8:7dc558da864d98b79f8d13a427ca3858', 'createTable tableName=view_log; createIndex indexName=idx_view_log_user_id, tableName=view_log; createIndex indexName=idx_view_log_timestamp, tableName=view_log', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::15::agilliland
ALTER TABLE `metabase_dev`.`revision` ADD `is_creation` BIT(1) DEFAULT 0 NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('15', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 14, '8:505b91530103673a9be3382cd2db1070', 'addColumn tableName=revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::16::agilliland
ALTER TABLE metabase_dev.core_user MODIFY last_login datetime NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('16', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 15, '8:b81df46fe16c3e8659a81798b97a4793', 'dropNotNullConstraint columnName=last_login, tableName=core_user', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::17::agilliland
ALTER TABLE metabase_dev.metabase_database ADD is_sample BIT(1) DEFAULT 0 NOT NULL;

update metabase_database set is_sample = true where name = 'Sample Dataset';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('17', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 16, '8:051c23cd15359364b9895c1569c319e7', 'addColumn tableName=metabase_database; sql', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::18::camsaul
CREATE TABLE metabase_dev.data_migrations (id VARCHAR(254) NOT NULL, timestamp datetime NOT NULL, CONSTRAINT PK_DATA_MIGRATIONS PRIMARY KEY (id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_data_migrations_id ON metabase_dev.data_migrations(id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('18', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 17, '8:62a0483dde183cfd18dd0a86e9354288', 'createTable tableName=data_migrations; createIndex indexName=idx_data_migrations_id, tableName=data_migrations', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::19::camsaul
ALTER TABLE metabase_dev.metabase_table ADD `schema` VARCHAR(256) NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('19', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 18, '8:269b129dbfc39a6f9e0d3bc61c3c3b70', 'addColumn tableName=metabase_table', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::20::agilliland
CREATE TABLE metabase_dev.pulse (id INT AUTO_INCREMENT NOT NULL, creator_id INT NOT NULL, name VARCHAR(254) NOT NULL, public_perms INT NOT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL, CONSTRAINT PK_PULSE PRIMARY KEY (id), CONSTRAINT fk_pulse_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_pulse_creator_id ON metabase_dev.pulse(creator_id);

CREATE TABLE metabase_dev.pulse_card (id INT AUTO_INCREMENT NOT NULL, pulse_id INT NOT NULL, card_id INT NOT NULL, position INT NOT NULL, CONSTRAINT PK_PULSE_CARD PRIMARY KEY (id), CONSTRAINT fk_pulse_card_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card(id), CONSTRAINT fk_pulse_card_ref_pulse_id FOREIGN KEY (pulse_id) REFERENCES metabase_dev.pulse(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_pulse_card_pulse_id ON metabase_dev.pulse_card(pulse_id);

CREATE INDEX idx_pulse_card_card_id ON metabase_dev.pulse_card(card_id);

CREATE TABLE metabase_dev.pulse_channel (id INT AUTO_INCREMENT NOT NULL, pulse_id INT NOT NULL, channel_type VARCHAR(32) NOT NULL, details TEXT NOT NULL, schedule_type VARCHAR(32) NOT NULL, schedule_hour INT NULL, schedule_day VARCHAR(64) NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL, CONSTRAINT PK_PULSE_CHANNEL PRIMARY KEY (id), CONSTRAINT fk_pulse_channel_ref_pulse_id FOREIGN KEY (pulse_id) REFERENCES metabase_dev.pulse(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_pulse_channel_pulse_id ON metabase_dev.pulse_channel(pulse_id);

CREATE INDEX idx_pulse_channel_schedule_type ON metabase_dev.pulse_channel(schedule_type);

CREATE TABLE metabase_dev.pulse_channel_recipient (id INT AUTO_INCREMENT NOT NULL, pulse_channel_id INT NOT NULL, user_id INT NOT NULL, CONSTRAINT PK_PULSE_CHANNEL_RECIPIENT PRIMARY KEY (id), CONSTRAINT fk_pulse_channel_recipient_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id), CONSTRAINT fk_pulse_channel_recipient_ref_pulse_channel_id FOREIGN KEY (pulse_channel_id) REFERENCES metabase_dev.pulse_channel(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('20', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 19, '8:7ec10b2c7acbab0fc38043be575ff907', 'createTable tableName=pulse; createIndex indexName=idx_pulse_creator_id, tableName=pulse; createTable tableName=pulse_card; createIndex indexName=idx_pulse_card_pulse_id, tableName=pulse_card; createIndex indexName=idx_pulse_card_card_id, tableNam...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::21::agilliland
CREATE TABLE metabase_dev.segment (id INT AUTO_INCREMENT NOT NULL, table_id INT NOT NULL, creator_id INT NOT NULL, name VARCHAR(254) NOT NULL, `description` TEXT NULL, is_active BIT(1) DEFAULT 1 NOT NULL, `definition` TEXT NOT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL, CONSTRAINT PK_SEGMENT PRIMARY KEY (id), CONSTRAINT fk_segment_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user(id), CONSTRAINT fk_segment_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase_dev.metabase_table(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_segment_creator_id ON metabase_dev.segment(creator_id);

CREATE INDEX idx_segment_table_id ON metabase_dev.segment(table_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('21', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 20, '8:492a1b64ff9c792aa6ba97d091819261', 'createTable tableName=segment; createIndex indexName=idx_segment_creator_id, tableName=segment; createIndex indexName=idx_segment_table_id, tableName=segment', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::22::agilliland
ALTER TABLE metabase_dev.revision ADD message TEXT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('22', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 21, '8:80bc8a62a90791a79adedcf1ac3c6f08', 'addColumn tableName=revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::23::agilliland
ALTER TABLE `metabase_dev`.`metabase_table` MODIFY `rows` BIGINT;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('23', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 22, '8:b6f054835db2b2688a1be1de3707f9a9', 'modifyDataType columnName=rows, tableName=metabase_table', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::24::agilliland
CREATE TABLE metabase_dev.dependency (id INT AUTO_INCREMENT NOT NULL, model VARCHAR(32) NOT NULL, model_id INT NOT NULL, dependent_on_model VARCHAR(32) NOT NULL, dependent_on_id INT NOT NULL, created_at datetime NOT NULL, CONSTRAINT PK_DEPENDENCY PRIMARY KEY (id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_dependency_model ON metabase_dev.dependency(model);

CREATE INDEX idx_dependency_model_id ON metabase_dev.dependency(model_id);

CREATE INDEX idx_dependency_dependent_on_model ON metabase_dev.dependency(dependent_on_model);

CREATE INDEX idx_dependency_dependent_on_id ON metabase_dev.dependency(dependent_on_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('24', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 23, '8:5e7354b3f92782d1151be0aa9d3fe625', 'createTable tableName=dependency; createIndex indexName=idx_dependency_model, tableName=dependency; createIndex indexName=idx_dependency_model_id, tableName=dependency; createIndex indexName=idx_dependency_dependent_on_model, tableName=dependency;...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::25::agilliland
CREATE TABLE metabase_dev.metric (id INT AUTO_INCREMENT NOT NULL, table_id INT NOT NULL, creator_id INT NOT NULL, name VARCHAR(254) NOT NULL, `description` TEXT NULL, is_active BIT(1) DEFAULT 1 NOT NULL, `definition` TEXT NOT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL, CONSTRAINT PK_METRIC PRIMARY KEY (id), CONSTRAINT fk_metric_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase_dev.metabase_table(id), CONSTRAINT fk_metric_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_metric_creator_id ON metabase_dev.metric(creator_id);

CREATE INDEX idx_metric_table_id ON metabase_dev.metric(table_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('25', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 24, '8:cea300a621393501d4534b0ff41eb91c', 'createTable tableName=metric; createIndex indexName=idx_metric_creator_id, tableName=metric; createIndex indexName=idx_metric_table_id, tableName=metric', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::26::agilliland
ALTER TABLE metabase_dev.metabase_database ADD is_full_sync BIT(1) DEFAULT 1 NOT NULL;

update metabase_database set is_full_sync = true;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('26', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 25, '8:ddef40b95c55cf4ac0e6a5161911a4cb', 'addColumn tableName=metabase_database; sql', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::27::agilliland
CREATE TABLE metabase_dev.dashboardcard_series (id INT AUTO_INCREMENT NOT NULL, dashboardcard_id INT NOT NULL, card_id INT NOT NULL, position INT NOT NULL, CONSTRAINT PK_DASHBOARDCARD_SERIES PRIMARY KEY (id), CONSTRAINT fk_dashboardcard_series_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card(id), CONSTRAINT fk_dashboardcard_series_ref_dashboardcard_id FOREIGN KEY (dashboardcard_id) REFERENCES metabase_dev.report_dashboardcard(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_dashboardcard_series_dashboardcard_id ON metabase_dev.dashboardcard_series(dashboardcard_id);

CREATE INDEX idx_dashboardcard_series_card_id ON metabase_dev.dashboardcard_series(card_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('27', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 26, '8:017050df833b3b678d1b52b1a0f4de50', 'createTable tableName=dashboardcard_series; createIndex indexName=idx_dashboardcard_series_dashboardcard_id, tableName=dashboardcard_series; createIndex indexName=idx_dashboardcard_series_card_id, tableName=dashboardcard_series', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::28::agilliland
ALTER TABLE metabase_dev.core_user ADD is_qbnewb BIT(1) DEFAULT 1 NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('28', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 27, '8:428e4eb05e4e29141735adf9ae141a0b', 'addColumn tableName=core_user', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::29::agilliland
ALTER TABLE metabase_dev.pulse_channel ADD schedule_frame VARCHAR(32) NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('29', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 28, '8:8b02731cc34add3722c926dfd7376ae0', 'addColumn tableName=pulse_channel', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::30::agilliland
ALTER TABLE metabase_dev.metabase_field ADD visibility_type VARCHAR(32) NULL;

UPDATE metabase_dev.metabase_field SET visibility_type = 'unset' WHERE visibility_type IS NULL;

ALTER TABLE metabase_dev.metabase_field MODIFY visibility_type VARCHAR(32) NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('30', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 29, '8:2c3a50cef177cb90d47a9973cd5934e5', 'addColumn tableName=metabase_field; addNotNullConstraint columnName=visibility_type, tableName=metabase_field', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::31::agilliland
ALTER TABLE metabase_dev.metabase_field ADD fk_target_field_id INT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('31', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 30, '8:30a33a82bab0bcbb2ccb6738d48e1421', 'addColumn tableName=metabase_field', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::32::camsaul
CREATE TABLE metabase_dev.label (id INT AUTO_INCREMENT NOT NULL, name VARCHAR(254) NOT NULL, slug VARCHAR(254) NOT NULL, icon VARCHAR(128) NULL, CONSTRAINT PK_LABEL PRIMARY KEY (id), UNIQUE (slug)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_label_slug ON metabase_dev.label(slug);

CREATE TABLE metabase_dev.card_label (id INT AUTO_INCREMENT NOT NULL, card_id INT NOT NULL, label_id INT NOT NULL, CONSTRAINT PK_CARD_LABEL PRIMARY KEY (id), CONSTRAINT fk_card_label_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card(id), CONSTRAINT fk_card_label_ref_label_id FOREIGN KEY (label_id) REFERENCES metabase_dev.label(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.card_label ADD CONSTRAINT unique_card_label_card_id_label_id UNIQUE (card_id, label_id);

CREATE INDEX idx_card_label_card_id ON metabase_dev.card_label(card_id);

CREATE INDEX idx_card_label_label_id ON metabase_dev.card_label(label_id);

ALTER TABLE metabase_dev.report_card ADD archived BIT(1) DEFAULT 0 NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('32', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 31, '8:40830260b92cedad8da273afd5eca678', 'createTable tableName=label; createIndex indexName=idx_label_slug, tableName=label; createTable tableName=card_label; addUniqueConstraint constraintName=unique_card_label_card_id_label_id, tableName=card_label; createIndex indexName=idx_card_label...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::32::agilliland
CREATE TABLE metabase_dev.raw_table (id INT AUTO_INCREMENT NOT NULL, database_id INT NOT NULL, active BIT(1) NOT NULL, `schema` VARCHAR(255) NULL, name VARCHAR(255) NOT NULL, details TEXT NOT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL, CONSTRAINT PK_RAW_TABLE PRIMARY KEY (id), CONSTRAINT fk_rawtable_ref_database FOREIGN KEY (database_id) REFERENCES metabase_dev.metabase_database(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_rawtable_database_id ON metabase_dev.raw_table(database_id);

ALTER TABLE metabase_dev.raw_table ADD CONSTRAINT uniq_raw_table_db_schema_name UNIQUE (database_id, `schema`, name);

CREATE TABLE metabase_dev.raw_column (id INT AUTO_INCREMENT NOT NULL, raw_table_id INT NOT NULL, active BIT(1) NOT NULL, name VARCHAR(255) NOT NULL, column_type VARCHAR(128) NULL, is_pk BIT(1) NOT NULL, fk_target_column_id INT NULL, details TEXT NOT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL, CONSTRAINT PK_RAW_COLUMN PRIMARY KEY (id), CONSTRAINT fk_rawcolumn_fktarget_ref_rawcolumn FOREIGN KEY (fk_target_column_id) REFERENCES metabase_dev.raw_column(id), CONSTRAINT fk_rawcolumn_tableid_ref_rawtable FOREIGN KEY (raw_table_id) REFERENCES metabase_dev.raw_table(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_rawcolumn_raw_table_id ON metabase_dev.raw_column(raw_table_id);

ALTER TABLE metabase_dev.raw_column ADD CONSTRAINT uniq_raw_column_table_name UNIQUE (raw_table_id, name);

ALTER TABLE metabase_dev.metabase_table ADD raw_table_id INT NULL;

ALTER TABLE metabase_dev.metabase_field ADD raw_column_id INT NULL;

ALTER TABLE metabase_dev.metabase_field ADD last_analyzed datetime NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('32', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 32, '8:ca6efc1c0a7aa82467d2c84421e812eb', 'createTable tableName=raw_table; createIndex indexName=idx_rawtable_database_id, tableName=raw_table; addUniqueConstraint constraintName=uniq_raw_table_db_schema_name, tableName=raw_table; createTable tableName=raw_column; createIndex indexName=id...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::34::tlrobinson
ALTER TABLE metabase_dev.pulse_channel ADD enabled BIT(1) DEFAULT 1 NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('34', 'tlrobinson', 'migrations/000_migrations.yaml', current_timestamp(6), 33, '8:52b082600b05bbbc46bfe837d1f37a82', 'addColumn tableName=pulse_channel', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::35::agilliland
ALTER TABLE metabase_dev.setting MODIFY value TEXT;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('35', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 34, '8:91b72167fca724e6b6a94b64f886cf09', 'modifyDataType columnName=value, tableName=setting', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::36::agilliland
ALTER TABLE metabase_dev.report_dashboard ADD parameters TEXT NULL;

UPDATE metabase_dev.report_dashboard SET parameters = '[]' WHERE parameters IS NULL;

ALTER TABLE metabase_dev.report_dashboard MODIFY parameters TEXT NOT NULL;

ALTER TABLE metabase_dev.report_dashboardcard ADD parameter_mappings TEXT NULL;

UPDATE metabase_dev.report_dashboardcard SET parameter_mappings = '[]' WHERE parameter_mappings IS NULL;

ALTER TABLE metabase_dev.report_dashboardcard MODIFY parameter_mappings TEXT NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('36', 'agilliland', 'migrations/000_migrations.yaml', current_timestamp(6), 35, '8:252e08892449dceb16c3d91337bd9573', 'addColumn tableName=report_dashboard; addNotNullConstraint columnName=parameters, tableName=report_dashboard; addColumn tableName=report_dashboardcard; addNotNullConstraint columnName=parameter_mappings, tableName=report_dashboardcard', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::37::tlrobinson
ALTER TABLE metabase_dev.query_queryexecution ADD query_hash INT NULL;

UPDATE metabase_dev.query_queryexecution SET query_hash = '0' WHERE query_hash IS NULL;

ALTER TABLE metabase_dev.query_queryexecution MODIFY query_hash INT NOT NULL;

CREATE INDEX idx_query_queryexecution_query_hash ON metabase_dev.query_queryexecution(query_hash);

CREATE INDEX idx_query_queryexecution_started_at ON metabase_dev.query_queryexecution(started_at);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('37', 'tlrobinson', 'migrations/000_migrations.yaml', current_timestamp(6), 36, '8:07d959eff81777e5690e2920583cfe5f', 'addColumn tableName=query_queryexecution; addNotNullConstraint columnName=query_hash, tableName=query_queryexecution; createIndex indexName=idx_query_queryexecution_query_hash, tableName=query_queryexecution; createIndex indexName=idx_query_querye...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::38::camsaul
ALTER TABLE metabase_dev.metabase_database ADD points_of_interest TEXT NULL;

ALTER TABLE metabase_dev.metabase_table ADD points_of_interest TEXT NULL;

ALTER TABLE metabase_dev.metabase_field ADD points_of_interest TEXT NULL;

ALTER TABLE metabase_dev.report_dashboard ADD points_of_interest TEXT NULL;

ALTER TABLE metabase_dev.metric ADD points_of_interest TEXT NULL;

ALTER TABLE metabase_dev.segment ADD points_of_interest TEXT NULL;

ALTER TABLE metabase_dev.metabase_database ADD caveats TEXT NULL;

ALTER TABLE metabase_dev.metabase_table ADD caveats TEXT NULL;

ALTER TABLE metabase_dev.metabase_field ADD caveats TEXT NULL;

ALTER TABLE metabase_dev.report_dashboard ADD caveats TEXT NULL;

ALTER TABLE metabase_dev.metric ADD caveats TEXT NULL;

ALTER TABLE metabase_dev.segment ADD caveats TEXT NULL;

ALTER TABLE metabase_dev.metric ADD how_is_this_calculated TEXT NULL;

ALTER TABLE metabase_dev.report_dashboard ADD show_in_getting_started BIT(1) DEFAULT 0 NOT NULL;

CREATE INDEX idx_report_dashboard_show_in_getting_started ON metabase_dev.report_dashboard(show_in_getting_started);

ALTER TABLE metabase_dev.metric ADD show_in_getting_started BIT(1) DEFAULT 0 NOT NULL;

CREATE INDEX idx_metric_show_in_getting_started ON metabase_dev.metric(show_in_getting_started);

ALTER TABLE metabase_dev.metabase_table ADD show_in_getting_started BIT(1) DEFAULT 0 NOT NULL;

CREATE INDEX idx_metabase_table_show_in_getting_started ON metabase_dev.metabase_table(show_in_getting_started);

ALTER TABLE metabase_dev.segment ADD show_in_getting_started BIT(1) DEFAULT 0 NOT NULL;

CREATE INDEX idx_segment_show_in_getting_started ON metabase_dev.segment(show_in_getting_started);

CREATE TABLE metabase_dev.metric_important_field (id INT AUTO_INCREMENT NOT NULL, metric_id INT NOT NULL, field_id INT NOT NULL, CONSTRAINT PK_METRIC_IMPORTANT_FIELD PRIMARY KEY (id), CONSTRAINT fk_metric_important_field_metric_id FOREIGN KEY (metric_id) REFERENCES metabase_dev.metric(id), CONSTRAINT fk_metric_important_field_metabase_field_id FOREIGN KEY (field_id) REFERENCES metabase_dev.metabase_field(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.metric_important_field ADD CONSTRAINT unique_metric_important_field_metric_id_field_id UNIQUE (metric_id, field_id);

CREATE INDEX idx_metric_important_field_metric_id ON metabase_dev.metric_important_field(metric_id);

CREATE INDEX idx_metric_important_field_field_id ON metabase_dev.metric_important_field(field_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('38', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 37, '8:43604ab55179b50306eb39353e760b46', 'addColumn tableName=metabase_database; addColumn tableName=metabase_table; addColumn tableName=metabase_field; addColumn tableName=report_dashboard; addColumn tableName=metric; addColumn tableName=segment; addColumn tableName=metabase_database; ad...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::39::camsaul
ALTER TABLE metabase_dev.core_user ADD google_auth BIT(1) DEFAULT 0 NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('39', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 38, '8:334adc22af5ded71ff27759b7a556951', 'addColumn tableName=core_user', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');


--  Changeset migrations/000_migrations.yaml::40::camsaul
CREATE TABLE metabase_dev.permissions_group (id INT AUTO_INCREMENT NOT NULL, name VARCHAR(255) NOT NULL, CONSTRAINT PK_PERMISSIONS_GROUP PRIMARY KEY (id), CONSTRAINT unique_permissions_group_name UNIQUE (name)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_permissions_group_name ON metabase_dev.permissions_group(name);

CREATE TABLE metabase_dev.permissions_group_membership (id INT AUTO_INCREMENT NOT NULL, user_id INT NOT NULL, group_id INT NOT NULL, CONSTRAINT PK_PERMISSIONS_GROUP_MEMBERSHIP PRIMARY KEY (id), CONSTRAINT fk_permissions_group_membership_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id), CONSTRAINT fk_permissions_group_group_id FOREIGN KEY (group_id) REFERENCES metabase_dev.permissions_group(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.permissions_group_membership ADD CONSTRAINT unique_permissions_group_membership_user_id_group_id UNIQUE (user_id, group_id);

CREATE INDEX idx_permissions_group_membership_group_id ON metabase_dev.permissions_group_membership(group_id);

CREATE INDEX idx_permissions_group_membership_user_id ON metabase_dev.permissions_group_membership(user_id);

CREATE INDEX idx_permissions_group_membership_group_id_user_id ON metabase_dev.permissions_group_membership(group_id, user_id);

CREATE TABLE metabase_dev.permissions (id INT AUTO_INCREMENT NOT NULL, object VARCHAR(254) NOT NULL, group_id INT NOT NULL, CONSTRAINT PK_PERMISSIONS PRIMARY KEY (id), CONSTRAINT fk_permissions_group_id FOREIGN KEY (group_id) REFERENCES metabase_dev.permissions_group(id)) ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE INDEX idx_permissions_group_id ON metabase_dev.permissions(group_id);

CREATE INDEX idx_permissions_object ON metabase_dev.permissions(object);

CREATE INDEX idx_permissions_group_id_object ON metabase_dev.permissions(group_id, object);

ALTER TABLE metabase_dev.permissions ADD UNIQUE (group_id, object);

-- set @@global.tidb_enable_change_column_type=true; -- useless
-- [x] Lossy ALTER not allowed for tidb, see https://docs.pingcap.com/tidb/stable/sql-statement-modify-column
--ALTER TABLE metabase_dev.metabase_table MODIFY `schema` VARCHAR(254);
ALTER TABLE metabase_dev.metabase_table DROP `schema`;
ALTER TABLE metabase_dev.metabase_table ADD column `schema` VARCHAR(254) AFTER visibility_type;


CREATE INDEX idx_metabase_table_db_id_schema ON metabase_dev.metabase_table(db_id, `schema`);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('40', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 39, '8:ee7f50a264d6cf8d891bd01241eebd2c', 'createTable tableName=permissions_group; createIndex indexName=idx_permissions_group_name, tableName=permissions_group; createTable tableName=permissions_group_membership; addUniqueConstraint constraintName=unique_permissions_group_membership_user...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');



--  Changeset migrations/000_migrations.yaml::41::camsaul
ALTER TABLE metabase_dev.metabase_field DROP COLUMN field_type;

ALTER TABLE metabase_dev.metabase_field ALTER active SET DEFAULT 1;

ALTER TABLE metabase_dev.metabase_field ALTER preview_display SET DEFAULT 1;

ALTER TABLE metabase_dev.metabase_field ALTER position SET DEFAULT 0;

ALTER TABLE metabase_dev.metabase_field ALTER visibility_type SET DEFAULT 'normal';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('41', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 40, '8:fae0855adf2f702f1133e32fc98d02a5', 'dropColumn columnName=field_type, tableName=metabase_field; addDefaultValue columnName=active, tableName=metabase_field; addDefaultValue columnName=preview_display, tableName=metabase_field; addDefaultValue columnName=position, tableName=metabase_...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');



--  Changeset migrations/000_migrations.yaml::42::camsaul
ALTER TABLE metabase_dev.query_queryexecution DROP FOREIGN KEY fk_queryexecution_ref_query_id;

ALTER TABLE metabase_dev.query_queryexecution DROP COLUMN query_id;

ALTER TABLE metabase_dev.core_user DROP COLUMN is_staff;

ALTER TABLE metabase_dev.metabase_database DROP COLUMN organization_id;

ALTER TABLE metabase_dev.report_card DROP COLUMN organization_id;

ALTER TABLE metabase_dev.report_dashboard DROP COLUMN organization_id;

DROP TABLE metabase_dev.annotation_annotation;

DROP TABLE metabase_dev.core_permissionsviolation;

DROP TABLE metabase_dev.core_userorgperm;

DROP TABLE metabase_dev.core_organization;

DROP TABLE metabase_dev.metabase_foreignkey;

DROP TABLE metabase_dev.metabase_tablesegment;

DROP TABLE metabase_dev.query_query;

DROP TABLE metabase_dev.report_dashboardsubscription;

DROP TABLE metabase_dev.report_emailreport_recipients;

DROP TABLE metabase_dev.report_emailreportexecutions;

DROP TABLE metabase_dev.report_emailreport;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('42', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 41, '8:e32b3a1624fa289a6ee1f3f0a2dac1f6', 'dropForeignKeyConstraint baseTableName=query_queryexecution, constraintName=fk_queryexecution_ref_query_id; dropColumn columnName=query_id, tableName=query_queryexecution; dropColumn columnName=is_staff, tableName=core_user; dropColumn columnName=...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');



--  Changeset migrations/000_migrations.yaml::43::camsaul
CREATE TABLE metabase_dev.permissions_revision (id INT AUTO_INCREMENT NOT NULL, `before` TEXT NOT NULL COMMENT 'Serialized JSON of the permissions before the changes.', after TEXT NOT NULL COMMENT 'Serialized JSON of the permissions after the changes.', user_id INT NOT NULL COMMENT 'The ID of the admin who made this set of changes.', created_at datetime NOT NULL COMMENT 'The timestamp of when these changes were made.', remark TEXT NULL COMMENT 'Optional remarks explaining why these changes were made.', CONSTRAINT PK_PERMISSIONS_REVISION PRIMARY KEY (id), CONSTRAINT fk_permissions_revision_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id)) COMMENT='Used to keep track of changes made to permissions.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.permissions_revision COMMENT = 'Used to keep track of changes made to permissions.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('43', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 42, '8:165e9384e46d6f9c0330784955363f70', 'createTable tableName=permissions_revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::44::camsaul
ALTER TABLE metabase_dev.report_card DROP COLUMN public_perms;

ALTER TABLE metabase_dev.report_dashboard DROP COLUMN public_perms;

ALTER TABLE metabase_dev.pulse DROP COLUMN public_perms;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('44', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 43, '8:2e356e8a1049286f1c78324828ee7867', 'dropColumn columnName=public_perms, tableName=report_card; dropColumn columnName=public_perms, tableName=report_dashboard; dropColumn columnName=public_perms, tableName=pulse', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');


--  Changeset migrations/000_migrations.yaml::45::tlrobinson
ALTER TABLE metabase_dev.report_dashboardcard ADD visualization_settings TEXT NULL;

UPDATE metabase_dev.report_dashboardcard SET visualization_settings = '{}' WHERE visualization_settings IS NULL;

ALTER TABLE metabase_dev.report_dashboardcard MODIFY visualization_settings TEXT NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('45', 'tlrobinson', 'migrations/000_migrations.yaml', current_timestamp(6), 44, '8:421edd38ee0cb0983162f57193f81b0b', 'addColumn tableName=report_dashboardcard; addNotNullConstraint columnName=visualization_settings, tableName=report_dashboardcard', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::46::camsaul
UPDATE `metabase_dev`.`report_dashboardcard` SET `row` = '0' WHERE `row` IS NULL;

ALTER TABLE `metabase_dev`.`report_dashboardcard` MODIFY `row` INT NOT NULL;

UPDATE `metabase_dev`.`report_dashboardcard` SET `col` = '0' WHERE `col` IS NULL;

ALTER TABLE `metabase_dev`.`report_dashboardcard` MODIFY `col` INT NOT NULL;

ALTER TABLE `metabase_dev`.`report_dashboardcard` ALTER `row` SET DEFAULT 0;

ALTER TABLE `metabase_dev`.`report_dashboardcard` ALTER `col` SET DEFAULT 0;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('46', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 45, '8:131df3cdd9a8c67b32c5988a3fb7fe3d', 'addNotNullConstraint columnName=row, tableName=report_dashboardcard; addNotNullConstraint columnName=col, tableName=report_dashboardcard; addDefaultValue columnName=row, tableName=report_dashboardcard; addDefaultValue columnName=col, tableName=rep...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');


--  Changeset migrations/000_migrations.yaml::47::camsaul
CREATE TABLE metabase_dev.collection (id INT AUTO_INCREMENT NOT NULL, name TEXT NOT NULL COMMENT 'The unique, user-facing name of this Collection.', slug VARCHAR(254) NOT NULL COMMENT 'URL-friendly, sluggified, indexed version of name.', `description` TEXT NULL COMMENT 'Optional description for this Collection.', color CHAR(7) NOT NULL COMMENT 'Seven-character hex color for this Collection, including the preceding hash sign.', archived BIT(1) DEFAULT 0 NOT NULL COMMENT 'Whether this Collection has been archived and should be hidden from users.', CONSTRAINT PK_COLLECTION PRIMARY KEY (id), UNIQUE (slug)) COMMENT='Collections are an optional way to organize Cards and handle permissions for them.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.collection COMMENT = 'Collections are an optional way to organize Cards and handle permissions for them.';

CREATE INDEX idx_collection_slug ON metabase_dev.collection(slug);

ALTER TABLE metabase_dev.report_card ADD collection_id INT NULL COMMENT 'Optional ID of Collection this Card belongs to.';

ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_card_collection_id FOREIGN KEY (collection_id) REFERENCES metabase_dev.collection (id);

CREATE INDEX idx_card_collection_id ON metabase_dev.report_card(collection_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('47', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 46, '8:1d2474e49a27db344c250872df58a6ed', 'createTable tableName=collection; createIndex indexName=idx_collection_slug, tableName=collection; addColumn tableName=report_card; createIndex indexName=idx_card_collection_id, tableName=report_card', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');



--  Changeset migrations/000_migrations.yaml::48::camsaul
CREATE TABLE metabase_dev.collection_revision (id INT AUTO_INCREMENT NOT NULL, `before` TEXT NOT NULL COMMENT 'Serialized JSON of the collections graph before the changes.', after TEXT NOT NULL COMMENT 'Serialized JSON of the collections graph after the changes.', user_id INT NOT NULL COMMENT 'The ID of the admin who made this set of changes.', created_at datetime NOT NULL COMMENT 'The timestamp of when these changes were made.', remark TEXT NULL COMMENT 'Optional remarks explaining why these changes were made.', CONSTRAINT PK_COLLECTION_REVISION PRIMARY KEY (id), CONSTRAINT fk_collection_revision_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id)) COMMENT='Used to keep track of changes made to collections.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.collection_revision COMMENT = 'Used to keep track of changes made to collections.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('48', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 47, '8:720ce9d4b9e6f0917aea035e9dc5d95d', 'createTable tableName=collection_revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');



--  Changeset migrations/000_migrations.yaml::49::camsaul
ALTER TABLE metabase_dev.report_card ADD public_uuid CHAR(36) NULL COMMENT 'Unique UUID used to in publically-accessible links to this Card.';

ALTER TABLE metabase_dev.report_card ADD UNIQUE (public_uuid);

ALTER TABLE metabase_dev.report_card ADD made_public_by_id INT NULL COMMENT 'The ID of the User who first publically shared this Card.';

ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_card_made_public_by_id FOREIGN KEY (made_public_by_id) REFERENCES metabase_dev.core_user (id);

CREATE INDEX idx_card_public_uuid ON metabase_dev.report_card(public_uuid);

ALTER TABLE metabase_dev.report_dashboard ADD public_uuid CHAR(36) NULL COMMENT 'Unique UUID used to in publically-accessible links to this Dashboard.';

ALTER TABLE metabase_dev.report_dashboard ADD UNIQUE (public_uuid);

ALTER TABLE metabase_dev.report_dashboard ADD made_public_by_id INT NULL COMMENT 'The ID of the User who first publically shared this Dashboard.';

ALTER TABLE metabase_dev.report_dashboard ADD CONSTRAINT fk_dashboard_made_public_by_id FOREIGN KEY (made_public_by_id) REFERENCES metabase_dev.core_user (id);

CREATE INDEX idx_dashboard_public_uuid ON metabase_dev.report_dashboard(public_uuid);

-- [x] fixed. set to NULL in the CREATION
-- ALTER TABLE metabase_dev.query_queryexecution MODIFY executor_id INT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('49', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 48, '8:4508e7d5f6d4da3c4a2de3bf5e3c5851', 'addColumn tableName=report_card; addColumn tableName=report_card; createIndex indexName=idx_card_public_uuid, tableName=report_card; addColumn tableName=report_dashboard; addColumn tableName=report_dashboard; createIndex indexName=idx_dashboard_pu...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::50::camsaul
ALTER TABLE metabase_dev.report_card ADD enable_embedding BIT(1) DEFAULT 0 NOT NULL COMMENT 'Is this Card allowed to be embedded in different websites (using a signed JWT)?';

ALTER TABLE metabase_dev.report_card ADD embedding_params TEXT NULL COMMENT 'Serialized JSON containing information about required parameters that must be supplied when embedding this Card.';

ALTER TABLE metabase_dev.report_dashboard ADD enable_embedding BIT(1) DEFAULT 0 NOT NULL COMMENT 'Is this Dashboard allowed to be embedded in different websites (using a signed JWT)?';

ALTER TABLE metabase_dev.report_dashboard ADD embedding_params TEXT NULL COMMENT 'Serialized JSON containing information about required parameters that must be supplied when embedding this Dashboard.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('50', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 49, '8:98a6ab6428ea7a589507464e34ade58a', 'addColumn tableName=report_card; addColumn tableName=report_card; addColumn tableName=report_dashboard; addColumn tableName=report_dashboard', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');


--  Changeset migrations/000_migrations.yaml::51::camsaul
-- [x] fixed alter timestamp(6) 168:: camsaul
CREATE TABLE metabase_dev.query_execution (id INT AUTO_INCREMENT NOT NULL, hash BINARY(32) NOT NULL COMMENT 'The hash of the query dictionary. This is a 256-bit SHA3 hash of the query.', started_at timestamp(6) NOT NULL COMMENT 'Timestamp of when this query started running.', running_time INT NOT NULL COMMENT 'The time, in milliseconds, this query took to complete.', result_rows INT NOT NULL COMMENT 'Number of rows in the query results.', native BIT(1) NOT NULL COMMENT 'Whether the query was a native query, as opposed to an MBQL one (e.g., created with the GUI).', context VARCHAR(32) NULL COMMENT 'Short string specifying how this query was executed, e.g. in a Dashboard or Pulse.', error TEXT NULL COMMENT 'Error message returned by failed query, if any.', executor_id INT NULL COMMENT 'The ID of the User who triggered this query execution, if any.', card_id INT NULL COMMENT 'The ID of the Card (Question) associated with this query execution, if any.', dashboard_id INT NULL COMMENT 'The ID of the Dashboard associated with this query execution, if any.', pulse_id INT NULL COMMENT 'The ID of the Pulse associated with this query execution, if any.', CONSTRAINT PK_QUERY_EXECUTION PRIMARY KEY (id)) COMMENT='A log of executed queries, used for calculating historic execution times, auditing, and other purposes.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.query_execution COMMENT = 'A log of executed queries, used for calculating historic execution times, auditing, and other purposes.';

CREATE INDEX idx_query_execution_started_at ON metabase_dev.query_execution(started_at);

CREATE INDEX idx_query_execution_query_hash_started_at ON metabase_dev.query_execution(hash, started_at);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('51', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 50, '8:43c90b5b9f6c14bfd0e41cc0b184617e', 'createTable tableName=query_execution; createIndex indexName=idx_query_execution_started_at, tableName=query_execution; createIndex indexName=idx_query_execution_query_hash_started_at, tableName=query_execution', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::52::camsaul
-- [x] fixed
CREATE TABLE metabase_dev.query_cache (query_hash BINARY(32) NOT NULL, updated_at timestamp(6) NOT NULL COMMENT 'The timestamp of when these query results were last refreshed.', results BLOB NOT NULL COMMENT 'Cached, compressed results of running the query with the given hash.', CONSTRAINT PK_QUERY_CACHE PRIMARY KEY (query_hash)) COMMENT='Cached results of queries are stored here when using the DB-based query cache.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.query_cache COMMENT = 'Cached results of queries are stored here when using the DB-based query cache.';

CREATE INDEX idx_query_cache_updated_at ON metabase_dev.query_cache(updated_at);

ALTER TABLE metabase_dev.report_card ADD cache_ttl INT NULL COMMENT 'The maximum time, in seconds, to return cached results for this Card rather than running a new query.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('52', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 51, '8:329695cb161ceb86f6d9473819359351', 'createTable tableName=query_cache; createIndex indexName=idx_query_cache_updated_at, tableName=query_cache; addColumn tableName=report_card', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::53::camsaul
CREATE TABLE metabase_dev.query (query_hash BINARY(32) NOT NULL, average_execution_time INT NOT NULL COMMENT 'Average execution time for the query, round to nearest number of milliseconds. This is updated as a rolling average.', CONSTRAINT PK_QUERY PRIMARY KEY (query_hash)) COMMENT='Information (such as average execution time) for different queries that have been previously ran.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.query COMMENT = 'Information (such as average execution time) for different queries that have been previously ran.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('53', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 52, '8:78d015c5090c57cd6972eb435601d3d0', 'createTable tableName=query', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::54::tlrobinson
ALTER TABLE metabase_dev.pulse ADD skip_if_empty BIT(1) DEFAULT 0 NOT NULL COMMENT 'Skip a scheduled Pulse if none of its questions have any results';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('54', 'tlrobinson', 'migrations/000_migrations.yaml', current_timestamp(6), 53, '8:e410005b585f5eeb5f202076ff9468f7', 'addColumn tableName=pulse', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::55::camsaul
ALTER TABLE metabase_dev.report_dashboard ADD archived BIT(1) DEFAULT 0 NOT NULL COMMENT 'Is this Dashboard archived (effectively treated as deleted?)';

ALTER TABLE metabase_dev.report_dashboard ADD position INT NULL COMMENT 'The position this Dashboard should appear in the Dashboards list, lower-numbered positions appearing before higher numbered ones.';

CREATE TABLE metabase_dev.dashboard_favorite (id INT AUTO_INCREMENT NOT NULL, user_id INT NOT NULL COMMENT 'ID of the User who favorited the Dashboard.', dashboard_id INT NOT NULL COMMENT 'ID of the Dashboard favorited by the User.', CONSTRAINT PK_DASHBOARD_FAVORITE PRIMARY KEY (id), CONSTRAINT fk_dashboard_favorite_dashboard_id FOREIGN KEY (dashboard_id) REFERENCES metabase_dev.report_dashboard(id) ON DELETE CASCADE, CONSTRAINT fk_dashboard_favorite_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id) ON DELETE CASCADE) COMMENT='Presence of a row here indicates a given User has favorited a given Dashboard.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.dashboard_favorite COMMENT = 'Presence of a row here indicates a given User has favorited a given Dashboard.';

ALTER TABLE metabase_dev.dashboard_favorite ADD CONSTRAINT unique_dashboard_favorite_user_id_dashboard_id UNIQUE (user_id, dashboard_id);

CREATE INDEX idx_dashboard_favorite_user_id ON metabase_dev.dashboard_favorite(user_id);

CREATE INDEX idx_dashboard_favorite_dashboard_id ON metabase_dev.dashboard_favorite(dashboard_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('55', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 54, '8:11bbd199bfa57b908ea3b1a470197de9', 'addColumn tableName=report_dashboard; addColumn tableName=report_dashboard; createTable tableName=dashboard_favorite; addUniqueConstraint constraintName=unique_dashboard_favorite_user_id_dashboard_id, tableName=dashboard_favorite; createIndex inde...', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::56::wwwiiilll
--  Added 0.25.0
ALTER TABLE metabase_dev.core_user ADD ldap_auth BIT(1) DEFAULT 0 NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('56', 'wwwiiilll', 'migrations/000_migrations.yaml', current_timestamp(6), 55, '8:9f46051abaee599e2838733512a32ad0', 'addColumn tableName=core_user', 'Added 0.25.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::57::camsaul
--  Added 0.25.0
ALTER TABLE metabase_dev.report_card ADD result_metadata TEXT NULL COMMENT 'Serialized JSON containing metadata about the result columns from running the query.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('57', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 56, '8:aab81d477e2d19a9ab18c58b78c9af88', 'addColumn tableName=report_card', 'Added 0.25.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::58::senior
--  Added 0.25.0
CREATE TABLE metabase_dev.dimension (id INT AUTO_INCREMENT NOT NULL, field_id INT NOT NULL COMMENT 'ID of the field this dimension row applies to', name VARCHAR(254) NOT NULL COMMENT 'Short description used as the display name of this new column', type VARCHAR(254) NOT NULL COMMENT 'Either internal for a user defined remapping or external for a foreign key based remapping', human_readable_field_id INT NULL COMMENT 'Only used with external type remappings. Indicates which field on the FK related table to use for display', created_at datetime NOT NULL COMMENT 'The timestamp of when the dimension was created.', updated_at datetime NOT NULL COMMENT 'The timestamp of when these dimension was last updated.', CONSTRAINT PK_DIMENSION PRIMARY KEY (id), CONSTRAINT fk_dimension_ref_field_id FOREIGN KEY (field_id) REFERENCES metabase_dev.metabase_field(id) ON DELETE CASCADE, CONSTRAINT fk_dimension_displayfk_ref_field_id FOREIGN KEY (human_readable_field_id) REFERENCES metabase_dev.metabase_field(id) ON DELETE CASCADE) COMMENT='Stores references to alternate views of existing fields, such as remapping an integer to a description, like an enum' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.dimension COMMENT = 'Stores references to alternate views of existing fields, such as remapping an integer to a description, like an enum';

ALTER TABLE metabase_dev.dimension ADD CONSTRAINT unique_dimension_field_id_name UNIQUE (field_id, name);

CREATE INDEX idx_dimension_field_id ON metabase_dev.dimension(field_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('58', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 57, '8:3554219ca39e0fd682d0fba57531e917', 'createTable tableName=dimension; addUniqueConstraint constraintName=unique_dimension_field_id_name, tableName=dimension; createIndex indexName=idx_dimension_field_id, tableName=dimension', 'Added 0.25.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::59::camsaul
--  Added 0.26.0
ALTER TABLE metabase_dev.metabase_field ADD fingerprint TEXT NULL COMMENT 'Serialized JSON containing non-identifying information about this Field, such as min, max, and percent JSON. Used for classification.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('59', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 58, '8:5b6ce52371e0e9eee88e6d766225a94b', 'addColumn tableName=metabase_field', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::60::camsaul
--  Added 0.26.0
ALTER TABLE metabase_dev.metabase_database ADD metadata_sync_schedule VARCHAR(254) DEFAULT '0 50 * * * ? *' NOT NULL COMMENT 'The cron schedule string for when this database should undergo the metadata sync process (and analysis for new fields).';

ALTER TABLE metabase_dev.metabase_database ADD cache_field_values_schedule VARCHAR(254) DEFAULT '0 50 0 * * ? *' NOT NULL COMMENT 'The cron schedule string for when FieldValues for eligible Fields should be updated.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('60', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 59, '8:2141162a1c99a5dd95e5a67c5595e6d7', 'addColumn tableName=metabase_database; addColumn tableName=metabase_database', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::61::camsaul
--  Added 0.26.0
ALTER TABLE metabase_dev.metabase_field ADD fingerprint_version INT DEFAULT 0 NOT NULL COMMENT 'The version of the fingerprint for this Field. Used so we can keep track of which Fields need to be analyzed again when new things are added to fingerprints.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('61', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 60, '8:7dded6fd5bf74d79b9a0b62511981272', 'addColumn tableName=metabase_field', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::62::senior
--  Added 0.26.0
ALTER TABLE metabase_dev.metabase_database ADD timezone VARCHAR(254) NULL COMMENT 'Timezone identifier for the database, set by the sync process';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('62', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 61, '8:cb32e6eaa1a2140703def2730f81fef2', 'addColumn tableName=metabase_database', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::63::camsaul
--  Added 0.26.0
ALTER TABLE metabase_dev.metabase_database ADD is_on_demand BIT(1) DEFAULT 0 NOT NULL COMMENT 'Whether we should do On-Demand caching of FieldValues for this DB. This means FieldValues are updated when their Field is used in a Dashboard or Card param.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('63', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 62, '8:226f73b9f6617495892d281b0f8303db', 'addColumn tableName=metabase_database', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::64::senior
--  Added 0.26.0
ALTER TABLE metabase_dev.raw_table DROP FOREIGN KEY fk_rawtable_ref_database;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('64', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 63, '8:4dcc8ffd836b56756f494d5dfce07b50', 'dropForeignKeyConstraint baseTableName=raw_table, constraintName=fk_rawtable_ref_database', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::66::senior
--  Added 0.26.0
drop table if exists computation_job_result cascade;

drop table if exists computation_job cascade;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('66', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 64, '8:e77d66af8e3b83d46c5a0064a75a1aac', 'sql; sql', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::67::attekei
--  Added 0.27.0
CREATE TABLE metabase_dev.computation_job (id INT AUTO_INCREMENT NOT NULL, creator_id INT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL, type VARCHAR(254) NOT NULL, status VARCHAR(254) NOT NULL, CONSTRAINT PK_COMPUTATION_JOB PRIMARY KEY (id), CONSTRAINT fk_computation_job_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user(id)) COMMENT='Stores submitted async computation jobs.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.computation_job COMMENT = 'Stores submitted async computation jobs.';

CREATE TABLE metabase_dev.computation_job_result (id INT AUTO_INCREMENT NOT NULL, job_id INT NOT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL, permanence VARCHAR(254) NOT NULL, payload TEXT NOT NULL, CONSTRAINT PK_COMPUTATION_JOB_RESULT PRIMARY KEY (id), CONSTRAINT fk_computation_result_ref_job_id FOREIGN KEY (job_id) REFERENCES metabase_dev.computation_job(id)) COMMENT='Stores results of async computation jobs.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.computation_job_result COMMENT = 'Stores results of async computation jobs.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('67', 'attekei', 'migrations/000_migrations.yaml', current_timestamp(6), 65, '8:59dfc37744fc362e0e312488fbc9a69b', 'createTable tableName=computation_job; createTable tableName=computation_job_result', 'Added 0.27.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::68::sbelak
--  Added 0.27.0
ALTER TABLE metabase_dev.computation_job ADD context TEXT NULL;

ALTER TABLE metabase_dev.computation_job ADD ended_at datetime NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('68', 'sbelak', 'migrations/000_migrations.yaml', current_timestamp(6), 66, '8:b4ac06d133dfbdc6567d992c7e18c6ec', 'addColumn tableName=computation_job; addColumn tableName=computation_job', 'Added 0.27.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::69::senior
--  Added 0.27.0
ALTER TABLE metabase_dev.pulse ADD alert_condition VARCHAR(254) NULL COMMENT 'Condition (i.e. "rows" or "goal") used as a guard for alerts';

ALTER TABLE metabase_dev.pulse ADD alert_first_only BIT(1) NULL COMMENT 'True if the alert should be disabled after the first notification';

ALTER TABLE metabase_dev.pulse ADD alert_above_goal BIT(1) NULL COMMENT 'For a goal condition, alert when above the goal';

ALTER TABLE metabase_dev.pulse MODIFY name VARCHAR(254) NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('69', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 67, '8:eadbe00e97eb53df4b3df60462f593f6', 'addColumn tableName=pulse; addColumn tableName=pulse; addColumn tableName=pulse; dropNotNullConstraint columnName=name, tableName=pulse', 'Added 0.27.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::70::camsaul
--  Added 0.28.0
ALTER TABLE metabase_dev.metabase_field ADD database_type VARCHAR(255) NULL COMMENT 'The actual type of this column in the database. e.g. VARCHAR or TEXT.';

UPDATE metabase_dev.metabase_field SET database_type = '?' WHERE database_type IS NULL;

ALTER TABLE metabase_dev.metabase_field MODIFY database_type VARCHAR(255) NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('70', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 68, '8:4e4eff7abb983b1127a32ba8107e7fb8', 'addColumn tableName=metabase_field; addNotNullConstraint columnName=database_type, tableName=metabase_field', 'Added 0.28.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

-- No errors until here
--  Changeset migrations/000_migrations.yaml::71::camsaul
--  Added 0.28.0
-- [x] fixed for tidb
-- ALTER TABLE metabase_dev.report_dashboardcard MODIFY card_id INT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('71', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 69, '8:755e5c3dd8a55793f29b2c95cb79c211', 'dropNotNullConstraint columnName=card_id, tableName=report_dashboardcard', 'Added 0.28.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::72::senior
--  Added 0.28.0
ALTER TABLE metabase_dev.pulse_card ADD include_csv BIT(1) DEFAULT 0 NOT NULL COMMENT 'True if a CSV of the data should be included for this pulse card';

ALTER TABLE metabase_dev.pulse_card ADD include_xls BIT(1) DEFAULT 0 NOT NULL COMMENT 'True if a XLS of the data should be included for this pulse card';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('72', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 70, '8:4dc6debdf779ab9273cf2158a84bb154', 'addColumn tableName=pulse_card; addColumn tableName=pulse_card', 'Added 0.28.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::73::camsaul
--  Added 0.29.0
ALTER TABLE metabase_dev.metabase_database ADD options TEXT NULL COMMENT 'Serialized JSON containing various options like QB behavior.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('73', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 71, '8:3c0f03d18ff78a0bcc9915e1d9c518d6', 'addColumn tableName=metabase_database', 'Added 0.29.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::74::camsaul
--  Added 0.29.0
ALTER TABLE metabase_dev.metabase_field ADD has_field_values TEXT NULL COMMENT 'Whether we have FieldValues ("list"), should ad-hoc search ("search"), disable entirely ("none"), or infer dynamically (null)"';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('74', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 72, '8:16726d6560851325930c25caf3c8ab96', 'addColumn tableName=metabase_field', 'Added 0.29.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::75::camsaul
--  Added 0.28.2
ALTER TABLE metabase_dev.report_card ADD read_permissions TEXT NULL COMMENT 'Permissions required to view this Card and run its query.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('75', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 73, '8:6072cabfe8188872d8e3da9a675f88c1', 'addColumn tableName=report_card', 'Added 0.28.2', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::76::senior
--  Added 0.30.0
ALTER TABLE metabase_dev.metabase_table ADD fields_hash TEXT NULL COMMENT 'Computed hash of all of the fields associated to this table';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('76', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 74, '8:9b7190c9171ccca72617d508875c3c82', 'addColumn tableName=metabase_table', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::77::senior
--  Added 0.30.0
ALTER TABLE metabase_dev.core_user ADD login_attributes TEXT NULL COMMENT 'JSON serialized map with attributes used for row level permissions';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('77', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 75, '8:07f0a6cd8dbbd9b89be0bd7378f7bdc8', 'addColumn tableName=core_user', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::78::camsaul
--  Added 0.30.0
-- [x] fixed card_id NULL for 83::senior
CREATE TABLE metabase_dev.group_table_access_policy (id INT AUTO_INCREMENT NOT NULL, group_id INT NOT NULL COMMENT 'ID of the Permissions Group this policy affects.', table_id INT NOT NULL COMMENT 'ID of the Table that should get automatically replaced as query source for the Permissions Group.', card_id INT NULL COMMENT 'ID of the Card (Question) to be used to replace the Table.', attribute_remappings TEXT NULL COMMENT 'JSON-encoded map of user attribute identifier to the param name used in the Card.', CONSTRAINT PK_GROUP_TABLE_ACCESS_POLICY PRIMARY KEY (id), CONSTRAINT fk_gtap_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card(id), CONSTRAINT fk_gtap_table_id FOREIGN KEY (table_id) REFERENCES metabase_dev.metabase_table(id) ON DELETE CASCADE, CONSTRAINT fk_gtap_group_id FOREIGN KEY (group_id) REFERENCES metabase_dev.permissions_group(id) ON DELETE CASCADE) COMMENT='Records that a given Card (Question) should automatically replace a given Table as query source for a given a Perms Group.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.group_table_access_policy COMMENT = 'Records that a given Card (Question) should automatically replace a given Table as query source for a given a Perms Group.';

CREATE INDEX idx_gtap_table_id_group_id ON metabase_dev.group_table_access_policy(table_id, group_id);

ALTER TABLE metabase_dev.group_table_access_policy ADD CONSTRAINT unique_gtap_table_id_group_id UNIQUE (table_id, group_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('78', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 76, '8:1977d7278269cdd0dc4f941f9e82f548', 'createTable tableName=group_table_access_policy; createIndex indexName=idx_gtap_table_id_group_id, tableName=group_table_access_policy; addUniqueConstraint constraintName=unique_gtap_table_id_group_id, tableName=group_table_access_policy', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::79::camsaul
--  Added 0.30.0
ALTER TABLE metabase_dev.report_dashboard ADD collection_id INT NULL COMMENT 'Optional ID of Collection this Dashboard belongs to.';

ALTER TABLE metabase_dev.report_dashboard ADD CONSTRAINT fk_dashboard_collection_id FOREIGN KEY (collection_id) REFERENCES metabase_dev.collection (id);

CREATE INDEX idx_dashboard_collection_id ON metabase_dev.report_dashboard(collection_id);

ALTER TABLE metabase_dev.pulse ADD collection_id INT NULL COMMENT 'Options ID of Collection this Pulse belongs to.';

ALTER TABLE metabase_dev.pulse ADD CONSTRAINT fk_pulse_collection_id FOREIGN KEY (collection_id) REFERENCES metabase_dev.collection (id);

CREATE INDEX idx_pulse_collection_id ON metabase_dev.pulse(collection_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('79', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 77, '8:3f31cb67f9cdf7754ca95cade22d87a2', 'addColumn tableName=report_dashboard; createIndex indexName=idx_dashboard_collection_id, tableName=report_dashboard; addColumn tableName=pulse; createIndex indexName=idx_pulse_collection_id, tableName=pulse', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::80::camsaul
ALTER TABLE metabase_dev.collection ADD location VARCHAR(254) DEFAULT '/' NOT NULL COMMENT 'Directory-structure path of ancestor Collections. e.g. "/1/2/" means our Parent is Collection 2, and their parent is Collection 1.';

CREATE INDEX idx_collection_location ON metabase_dev.collection(location);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('80', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 78, '8:199d0ce28955117819ca15bcc29323e5', 'addColumn tableName=collection; createIndex indexName=idx_collection_location, tableName=collection', '', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::81::camsaul
--  Added 0.30.0
ALTER TABLE metabase_dev.report_dashboard ADD collection_position SMALLINT NULL COMMENT 'Optional pinned position for this item in its Collection. NULL means item is not pinned.';

ALTER TABLE metabase_dev.report_card ADD collection_position SMALLINT NULL COMMENT 'Optional pinned position for this item in its Collection. NULL means item is not pinned.';

ALTER TABLE metabase_dev.pulse ADD collection_position SMALLINT NULL COMMENT 'Optional pinned position for this item in its Collection. NULL means item is not pinned.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('81', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 79, '8:3a6dc22403660529194d004ca7f7ad39', 'addColumn tableName=report_dashboard; addColumn tableName=report_card; addColumn tableName=pulse', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::82::senior
--  Added 0.30.0
ALTER TABLE metabase_dev.core_user ADD updated_at datetime NULL COMMENT 'When was this User last updated?';

update core_user set updated_at=date_joined;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('82', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 80, '8:ac4b94df8c648f88cfff661284d6392d', 'addColumn tableName=core_user; sql', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::83::senior
--  Added 0.30.0
-- [x] fixed for tidb
-- ALTER TABLE metabase_dev.group_table_access_policy MODIFY card_id INT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('83', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 81, '8:ccd897d737737c05248293c7d56efe96', 'dropNotNullConstraint columnName=card_id, tableName=group_table_access_policy', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::84::senior
--  Added 0.30.0
ALTER TABLE metabase_dev.metric CHANGE is_active archived BIT(1);

ALTER TABLE metabase_dev.metric ALTER archived SET DEFAULT 0;

ALTER TABLE metabase_dev.segment CHANGE is_active archived BIT(1);

ALTER TABLE metabase_dev.segment ALTER archived SET DEFAULT 0;

ALTER TABLE metabase_dev.pulse ADD archived BIT(1) DEFAULT 0 NULL COMMENT 'Has this pulse been archived?';

update segment set archived = not(archived);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('84', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 82, '8:58afc10c3e283a8050ea471aac447a97', 'renameColumn newColumnName=archived, oldColumnName=is_active, tableName=metric; addDefaultValue columnName=archived, tableName=metric; renameColumn newColumnName=archived, oldColumnName=is_active, tableName=segment; addDefaultValue columnName=arch...', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::85::camsaul
--  Added 0.30.0
ALTER TABLE metabase_dev.collection ADD personal_owner_id INT NULL COMMENT 'If set, this Collection is a personal Collection, for exclusive use of the User with this ID.';

ALTER TABLE metabase_dev.collection ADD CONSTRAINT unique_collection_personal_owner_id UNIQUE (personal_owner_id);

ALTER TABLE metabase_dev.collection ADD CONSTRAINT fk_collection_personal_owner_id FOREIGN KEY (personal_owner_id) REFERENCES metabase_dev.core_user (id);

CREATE INDEX idx_collection_personal_owner_id ON metabase_dev.collection(personal_owner_id);

ALTER TABLE metabase_dev.collection ADD _slug VARCHAR(254) NULL COMMENT 'Sluggified version of the Collection name. Used only for display purposes in URL; not unique or indexed.';

UPDATE collection SET _slug = slug;

ALTER TABLE metabase_dev.collection MODIFY _slug VARCHAR(254) NOT NULL;

ALTER TABLE metabase_dev.collection DROP COLUMN slug;

ALTER TABLE metabase_dev.collection CHANGE _slug slug VARCHAR(254);

ALTER TABLE `collection` CHANGE `name` `name` TEXT NOT NULL COMMENT 'The user-facing name of this Collection.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('85', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 83, '8:9b4c9878a5018452dd63eb6d7c17f415', 'addColumn tableName=collection; createIndex indexName=idx_collection_personal_owner_id, tableName=collection; addColumn tableName=collection; sql; addNotNullConstraint columnName=_slug, tableName=collection; dropColumn columnName=slug, tableName=c...', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::86::camsaul
--  Added 0.30.0
DELETE FROM permissions WHERE object LIKE '%/native/read/';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('86', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 84, '8:50c75bb29f479e0b3fb782d89f7d6717', 'sql', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::87::camsaul
--  Added 0.30.0
DROP TABLE metabase_dev.raw_column;

DROP TABLE metabase_dev.raw_table;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('87', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 85, '8:0eccf19a93cb0ba4017aafd1d308c097', 'dropTable tableName=raw_column; dropTable tableName=raw_table', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::88::senior
--  Added 0.30.0
ALTER TABLE metabase_dev.core_user ADD saml_auth BIT(1) DEFAULT 0 NOT NULL COMMENT 'Boolean to indicate if this user is authenticated via SAML';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('88', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 86, '8:04ff5a0738473938fc31d68c1d9952e1', 'addColumn tableName=core_user', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

-- [x] kuiyu error free here

--  Changeset migrations/000_migrations.yaml::89::camsaul
--  Added 0.30.0
-- [x] 01 modified for tidb
CREATE TABLE metabase_dev.QRTZ_JOB_DETAILS (SCHED_NAME VARCHAR(120) NOT NULL, JOB_NAME VARCHAR(200) NOT NULL, JOB_GROUP VARCHAR(200) NOT NULL, `DESCRIPTION` VARCHAR(250) NULL, JOB_CLASS_NAME VARCHAR(250) NOT NULL, IS_DURABLE BIT(1) NOT NULL, IS_NONCONCURRENT BIT(1) NOT NULL, IS_UPDATE_DATA BIT(1) NOT NULL, REQUESTS_RECOVERY BIT(1) NOT NULL, JOB_DATA BLOB NULL,
PRIMARY KEY (SCHED_NAME, JOB_NAME, JOB_GROUP)
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_JOB_DETAILS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_JOB_DETAILS ADD PRIMARY KEY (SCHED_NAME, JOB_NAME, JOB_GROUP);

-- [x] 02 modified for tidb
CREATE TABLE metabase_dev.QRTZ_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, JOB_NAME VARCHAR(200) NOT NULL, JOB_GROUP VARCHAR(200) NOT NULL, `DESCRIPTION` VARCHAR(250) NULL, NEXT_FIRE_TIME BIGINT NULL, PREV_FIRE_TIME BIGINT NULL, PRIORITY INT NULL, TRIGGER_STATE VARCHAR(16) NOT NULL, TRIGGER_TYPE VARCHAR(8) NOT NULL, START_TIME BIGINT NOT NULL, END_TIME BIGINT NULL, CALENDAR_NAME VARCHAR(200) NULL, MISFIRE_INSTR SMALLINT NULL, JOB_DATA BLOB NULL,
PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) 
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_TRIGGERS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_TRIGGERS ADD PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase_dev.QRTZ_TRIGGERS ADD CONSTRAINT FK_QRTZ_TRIGGERS_JOB_DETAILS FOREIGN KEY (SCHED_NAME, JOB_NAME, JOB_GROUP) REFERENCES metabase_dev.QRTZ_JOB_DETAILS (SCHED_NAME, JOB_NAME, JOB_GROUP);

-- [x] 03 modified for tidb
CREATE TABLE metabase_dev.QRTZ_SIMPLE_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, REPEAT_COUNT BIGINT NOT NULL, REPEAT_INTERVAL BIGINT NOT NULL, TIMES_TRIGGERED BIGINT NOT NULL,
PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) 
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_SIMPLE_TRIGGERS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_SIMPLE_TRIGGERS ADD PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase_dev.QRTZ_SIMPLE_TRIGGERS ADD CONSTRAINT FK_QRTZ_SIMPLE_TRIGGERS_TRIGGERS FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) REFERENCES metabase_dev.QRTZ_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

-- [x] 04 modified for tidb
CREATE TABLE metabase_dev.QRTZ_CRON_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, CRON_EXPRESSION VARCHAR(120) NOT NULL, TIME_ZONE_ID VARCHAR(80) NULL,
PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) 
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_CRON_TRIGGERS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_CRON_TRIGGERS ADD PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase_dev.QRTZ_CRON_TRIGGERS ADD CONSTRAINT FK_QRTZ_CRON_TRIGGERS_TRIGGERS FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) REFERENCES metabase_dev.QRTZ_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

-- [x] 05 modified for tidb
CREATE TABLE metabase_dev.QRTZ_SIMPROP_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, STR_PROP_1 VARCHAR(512) NULL, STR_PROP_2 VARCHAR(512) NULL, STR_PROP_3 VARCHAR(512) NULL, INT_PROP_1 INT NULL, INT_PROP_2 INT NULL, LONG_PROP_1 BIGINT NULL, LONG_PROP_2 BIGINT NULL, DEC_PROP_1 numeric(13, 4) NULL, DEC_PROP_2 numeric(13, 4) NULL, BOOL_PROP_1 BIT(1) NULL, BOOL_PROP_2 BIT(1) NULL,
PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_SIMPROP_TRIGGERS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_SIMPROP_TRIGGERS ADD PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase_dev.QRTZ_SIMPROP_TRIGGERS ADD CONSTRAINT FK_QRTZ_SIMPROP_TRIGGERS_TRIGGERS FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) REFERENCES metabase_dev.QRTZ_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

-- [x] 06 modified for tidb
CREATE TABLE metabase_dev.QRTZ_BLOB_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, BLOB_DATA BLOB NULL,
PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_BLOB_TRIGGERS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_BLOB_TRIGGERS ADD PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase_dev.QRTZ_BLOB_TRIGGERS ADD CONSTRAINT FK_QRTZ_BLOB_TRIGGERS_TRIGGERS FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) REFERENCES metabase_dev.QRTZ_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

-- [x] 07 modified for tidb
CREATE TABLE metabase_dev.QRTZ_CALENDARS (SCHED_NAME VARCHAR(120) NOT NULL, CALENDAR_NAME VARCHAR(200) NOT NULL, CALENDAR BLOB NOT NULL,
PRIMARY KEY (SCHED_NAME, CALENDAR_NAME)
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_CALENDARS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_CALENDARS ADD PRIMARY KEY (SCHED_NAME, CALENDAR_NAME);

-- [x] 08 modified for tidb
CREATE TABLE metabase_dev.QRTZ_PAUSED_TRIGGER_GRPS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL,
PRIMARY KEY (SCHED_NAME, TRIGGER_GROUP)
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_PAUSED_TRIGGER_GRPS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
--ALTER TABLE metabase_dev.QRTZ_PAUSED_TRIGGER_GRPS ADD PRIMARY KEY (SCHED_NAME, TRIGGER_GROUP);

-- [x] 09 modified for tidb
CREATE TABLE metabase_dev.QRTZ_FIRED_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, ENTRY_ID VARCHAR(95) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, INSTANCE_NAME VARCHAR(200) NOT NULL, FIRED_TIME BIGINT NOT NULL, SCHED_TIME BIGINT NULL, PRIORITY INT NOT NULL, STATE VARCHAR(16) NOT NULL, JOB_NAME VARCHAR(200) NULL, JOB_GROUP VARCHAR(200) NULL, IS_NONCONCURRENT BIT(1) NULL, REQUESTS_RECOVERY BIT(1) NULL,
PRIMARY KEY (SCHED_NAME, ENTRY_ID)
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_FIRED_TRIGGERS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_FIRED_TRIGGERS ADD PRIMARY KEY (SCHED_NAME, ENTRY_ID);

-- [x] 10 modified for tidb
CREATE TABLE metabase_dev.QRTZ_SCHEDULER_STATE (SCHED_NAME VARCHAR(120) NOT NULL, INSTANCE_NAME VARCHAR(200) NOT NULL, LAST_CHECKIN_TIME BIGINT NOT NULL, CHECKIN_INTERVAL BIGINT NOT NULL,
PRIMARY KEY (SCHED_NAME, INSTANCE_NAME)
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_SCHEDULER_STATE COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_SCHEDULER_STATE ADD PRIMARY KEY (SCHED_NAME, INSTANCE_NAME);

-- [x] 11 modified for tidb
CREATE TABLE metabase_dev.QRTZ_LOCKS (SCHED_NAME VARCHAR(120) NOT NULL, LOCK_NAME VARCHAR(40) NOT NULL,
PRIMARY KEY (SCHED_NAME, LOCK_NAME)
) COMMENT='Used for Quartz scheduler.' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.QRTZ_LOCKS COMMENT = 'Used for Quartz scheduler.';

-- [x] tidb does no support adding primary key. moved to CREATE TABLE
-- ALTER TABLE metabase_dev.QRTZ_LOCKS ADD PRIMARY KEY (SCHED_NAME, LOCK_NAME);

CREATE INDEX IDX_QRTZ_J_REQ_RECOVERY ON metabase_dev.QRTZ_JOB_DETAILS(SCHED_NAME, REQUESTS_RECOVERY);

CREATE INDEX IDX_QRTZ_J_GRP ON metabase_dev.QRTZ_JOB_DETAILS(SCHED_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_T_J ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, JOB_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_T_JG ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_T_C ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, CALENDAR_NAME);

CREATE INDEX IDX_QRTZ_T_G ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_GROUP);

CREATE INDEX IDX_QRTZ_T_STATE ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_T_N_STATE ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_T_N_G_STATE ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_GROUP, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_T_NEXT_FIRE_TIME ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, NEXT_FIRE_TIME);

CREATE INDEX IDX_QRTZ_T_NFT_ST ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_STATE, NEXT_FIRE_TIME);

CREATE INDEX IDX_QRTZ_T_NFT_MISFIRE ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME);

CREATE INDEX IDX_QRTZ_T_NFT_ST_MISFIRE ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_T_NFT_ST_MISFIRE_GRP ON metabase_dev.QRTZ_TRIGGERS(SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME, TRIGGER_GROUP, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_FT_TRIG_INST_NAME ON metabase_dev.QRTZ_FIRED_TRIGGERS(SCHED_NAME, INSTANCE_NAME);

CREATE INDEX IDX_QRTZ_FT_INST_JOB_REQ_RCVRY ON metabase_dev.QRTZ_FIRED_TRIGGERS(SCHED_NAME, INSTANCE_NAME, REQUESTS_RECOVERY);

CREATE INDEX IDX_QRTZ_FT_J_G ON metabase_dev.QRTZ_FIRED_TRIGGERS(SCHED_NAME, JOB_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_FT_JG ON metabase_dev.QRTZ_FIRED_TRIGGERS(SCHED_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_FT_T_G ON metabase_dev.QRTZ_FIRED_TRIGGERS(SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

CREATE INDEX IDX_QRTZ_FT_TG ON metabase_dev.QRTZ_FIRED_TRIGGERS(SCHED_NAME, TRIGGER_GROUP);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('89', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 87, '8:ab526907b26b1bb43ac9f9548043f2a7', 'createTable tableName=QRTZ_JOB_DETAILS; addPrimaryKey constraintName=PK_QRTZ_JOB_DETAILS, tableName=QRTZ_JOB_DETAILS; createTable tableName=QRTZ_TRIGGERS; addPrimaryKey constraintName=PK_QRTZ_TRIGGERS, tableName=QRTZ_TRIGGERS; addForeignKeyConstra...', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::90::senior
--  Added 0.30.0
ALTER TABLE metabase_dev.core_user ADD sso_source VARCHAR(254) NULL COMMENT 'String to indicate the SSO backend the user is from';

update core_user set sso_source='saml' where saml_auth=true;

ALTER TABLE metabase_dev.core_user DROP COLUMN saml_auth;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('90', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 88, '8:8562a72a1190deadc5fa59a23a6396dc', 'addColumn tableName=core_user; sql; dropColumn columnName=saml_auth, tableName=core_user', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::91::camsaul
--  Added 0.30.0
ALTER TABLE metabase_dev.metabase_table DROP COLUMN raw_table_id;

ALTER TABLE metabase_dev.metabase_field DROP COLUMN raw_column_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('91', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 89, '8:9b8831e1e409f08e874c4ece043d0340', 'dropColumn columnName=raw_table_id, tableName=metabase_table; dropColumn columnName=raw_column_id, tableName=metabase_field', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::92::camsaul
--  Added 0.31.0
ALTER TABLE metabase_dev.query_execution ADD database_id INT NULL COMMENT 'ID of the database this query was ran against.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('92', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 90, '8:1e5bc2d66778316ea640a561862c23b4', 'addColumn tableName=query_execution', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::93::camsaul
--  Added 0.31.0
ALTER TABLE metabase_dev.query ADD query TEXT NULL COMMENT 'The actual "query dictionary" for this query.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('93', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 91, '8:93b0d408a3970e30d7184ed1166b5476', 'addColumn tableName=query', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::94::senior
--  Added 0.31.0
CREATE TABLE metabase_dev.task_history (id INT AUTO_INCREMENT NOT NULL, task VARCHAR(254) NOT NULL COMMENT 'Name of the task', db_id INT NULL, started_at datetime NOT NULL, ended_at datetime NOT NULL, duration INT NOT NULL, task_details TEXT NULL COMMENT 'JSON string with additional info on the task', CONSTRAINT PK_TASK_HISTORY PRIMARY KEY (id)) COMMENT='Timing and metadata info about background/quartz processes' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.task_history COMMENT = 'Timing and metadata info about background/quartz processes';

CREATE INDEX idx_task_history_end_time ON metabase_dev.task_history(ended_at);

CREATE INDEX idx_task_history_db_id ON metabase_dev.task_history(db_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('94', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 92, '8:a2a1eedf1e8f8756856c9d49c7684bfe', 'createTable tableName=task_history; createIndex indexName=idx_task_history_end_time, tableName=task_history; createIndex indexName=idx_task_history_db_id, tableName=task_history', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::95::senior
--  Added 0.31.0
ALTER TABLE metabase_dev.DATABASECHANGELOG ADD CONSTRAINT idx_databasechangelog_id_author_filename UNIQUE (id, author, filename);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('95', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 93, '8:9824808283004e803003b938399a4cf0', 'addUniqueConstraint constraintName=idx_databasechangelog_id_author_filename, tableName=DATABASECHANGELOG', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::96::camsaul
--  Added 0.31.0
ALTER TABLE metabase_dev.metabase_field ADD settings TEXT NULL COMMENT 'Serialized JSON FE-specific settings like formatting, etc. Scope of what is stored here may increase in future.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('96', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 94, '8:5cb2f36edcca9c6e14c5e109d6aeb68b', 'addColumn tableName=metabase_field', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::97::senior
--  Added 0.32.0
ALTER TABLE metabase_dev.query_cache MODIFY results LONGBLOB;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('97', 'senior', 'migrations/000_migrations.yaml', current_timestamp(6), 95, '8:9169e238663c5d036bd83428d2fa8e4b', 'modifyDataType columnName=results, tableName=query_cache', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::98::camsaul
--  Added 0.32.0
ALTER TABLE metabase_dev.metabase_table ADD CONSTRAINT idx_uniq_table_db_id_schema_name UNIQUE (db_id, `schema`, name);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('98', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 96, '8:f036d20a4dc86fb60ffb64ea838ed6b9', 'addUniqueConstraint constraintName=idx_uniq_table_db_id_schema_name, tableName=metabase_table; sql', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::99::camsaul
--  Added 0.32.0
ALTER TABLE metabase_dev.metabase_field ADD CONSTRAINT idx_uniq_field_table_id_parent_id_name UNIQUE (table_id, parent_id, name);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('99', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 97, '8:274bb516dd95b76c954b26084eed1dfe', 'addUniqueConstraint constraintName=idx_uniq_field_table_id_parent_id_name, tableName=metabase_field; sql', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::100::camsaul
--  Added 0.32.0
UPDATE metric SET archived = NOT archived WHERE EXISTS (
  SELECT *
  FROM databasechangelog dbcl
  WHERE dbcl.id = '84'
    AND metric.updated_at < dbcl.dateexecuted
);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('100', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 98, '8:948014f13b6198b50e3b7a066fae2ae0', 'sql', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::101::camsaul
--  Added 0.32.0
CREATE INDEX idx_field_parent_id ON metabase_dev.metabase_field(parent_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('101', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 99, '8:58eabb08a175fafe8985208545374675', 'createIndex indexName=idx_field_parent_id, tableName=metabase_field', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::103::camsaul
--  Added 0.32.10
ALTER TABLE metabase_dev.metabase_database ADD auto_run_queries BIT(1) DEFAULT 1 NOT NULL COMMENT 'Whether to automatically run queries when doing simple filtering and summarizing in the Query Builder.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('103', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 100, '8:fda3670fd16a40fd9d0f89a003098d54', 'addColumn tableName=metabase_database', 'Added 0.32.10', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::104::camsaul
--  Added EE 1.1.6/CE 0.33.0
ALTER TABLE metabase_dev.core_session ADD anti_csrf_token TEXT NULL COMMENT 'Anti-CSRF token for full-app embed sessions.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('104', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 101, '8:21709f17e6d1b521d3d3b8cbb5445218', 'addColumn tableName=core_session', 'Added EE 1.1.6/CE 0.33.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::106::sb
--  Added 0.33.5
ALTER TABLE metabase_dev.metabase_field MODIFY database_type TEXT;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('106', 'sb', 'migrations/000_migrations.yaml', current_timestamp(6), 102, '8:a3dd42bbe25c415ce21e4c180dc1c1d7', 'modifyDataType columnName=database_type, tableName=metabase_field', 'Added 0.33.5', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::107::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('107', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 103, '8:605c2b4d212315c83727aa3d914cf57f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::108::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('108', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 104, '8:d11419da9384fd27d7b1670707ac864c', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::109::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('109', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 105, '8:a5f4ea412eb1d5c1bc824046ad11692f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::110::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('110', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 106, '8:82343097044b9652f73f3d3a2ddd04fe', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::111::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('111', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 107, '8:528de1245ba3aa106871d3e5b3eee0ba', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::112::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('112', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 108, '8:010a3931299429d1adfa91941c806ea4', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::113::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('113', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 109, '8:8f8e0836064bdea82487ecf64a129767', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::114::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('114', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 110, '8:7a0bcb25ece6d9a311d6c6be7ed89bb7', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::115::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('115', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 111, '8:55c10c2ff7e967e3ea1fdffc5aeed93a', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::116::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('116', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 112, '8:dbf7c3a1d8b1eb77b7f5888126b13c2e', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::117::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('117', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 113, '8:f2d7f9fb1b6713bc5362fe40bfe3f91f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::118::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('118', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 114, '8:17f4410e30a0c7e84a36517ebf4dab64', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::119::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('119', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 115, '8:195cf171ac1d5531e455baf44d9d6561', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::120::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('120', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 116, '8:61f53fac337020aec71868656a719bba', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::121::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('121', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 117, '8:1baa145d2ffe1e18d097a63a95476c5f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::122::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('122', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 118, '8:929b3c551a8f631cdce2511612d82d62', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::123::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('123', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 119, '8:35e5baddf78df5829fe6889d216436e5', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::124::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('124', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 120, '8:ce2322ca187dfac51be8f12f6a132818', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::125::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('125', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 121, '8:dd948ac004ceb9d0a300a8e06806945f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::126::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('126', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 122, '8:3d34c0d4e5dbb32b432b83d5322e2aa3', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::127::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('127', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 123, '8:18314b269fe11898a433ca9048400975', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::128::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('128', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 124, '8:44acbe257817286d88b7892e79363b66', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::129::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('129', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 125, '8:f890168c47cc2113a8af77ed3875c4b3', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::130::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('130', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 126, '8:ecdcf1fd66b3477e5b6882c3286b2fd8', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::131::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('131', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 127, '8:453af2935194978c65b19eae445d85c9', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::132::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('132', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 128, '8:d2c37bc80b42a15b65f148bcb1daa86e', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::133::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('133', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 129, '8:5b9b539d146fbdb762577dc98e7f3430', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::134::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('134', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 130, '8:4d0f688a168db3e357a808263b6ad355', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::135::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('135', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 131, '8:2ca54b0828c6aca615fb42064f1ec728', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::136::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('136', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 132, '8:7115eebbcf664509b9fc0c39cb6f29e9', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::137::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('137', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 133, '8:da754ac6e51313a32de6f6389b29e1ca', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::138::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('138', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 134, '8:bfb201761052189e96538f0de3ac76cf', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::139::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('139', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 135, '8:fdad4ec86aefb0cdf850b1929b618508', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::140::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('140', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 136, '8:a0cfe6468160bba8c9d602da736c41fb', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::141::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('141', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 137, '8:b6b7faa02cba069e1ed13e365f59cb6b', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::142::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('142', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 138, '8:0c291eb50cc0f1fef3d55cfe6b62bedb', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::143::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('143', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 139, '8:3d9a5cb41f77a33e834d0562fdddeab6', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::144::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('144', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 140, '8:1d5b7f79f97906105e90d330a17c4062', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::145::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('145', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 141, '8:b162dd48ef850ab4300e2d714eac504e', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::146::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('146', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 142, '8:8c0c1861582d15fe7859358f5d553c91', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::147::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('147', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 143, '8:5ccf590332ea0744414e40a990a43275', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::148::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('148', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 144, '8:12b42e87d40cd7b6399c1fb0c6704fa7', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::149::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('149', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 145, '8:dd45bfc4af5e05701a064a5f2a046d7f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::150::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('150', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 146, '8:48beda94aeaa494f798c38a66b90fb2a', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::151::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('151', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 147, '8:bb752a7d09d437c7ac294d5ab2600079', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::152::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('152', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 148, '8:4bcbc472f2d6ae3a5e7eca425940e52b', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::153::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('153', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 149, '8:adce2cca96fe0531b00f9bed6bed8352', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::154::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('154', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 150, '8:7a1df4f7a679f47459ea1a1c0991cfba', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::155::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('155', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 151, '8:3c78b79c784e3a3ce09a77db1b1d0374', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::156::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('156', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 152, '8:51859ee6cca4aca9d141a3350eb5d6b1', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::157::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('157', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 153, '8:0197c46bf8536a75dbf7e9aee731f3b2', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::158::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('158', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 154, '8:2ebdd5a179ce2487b2e23b6be74a407c', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::159::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('159', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 155, '8:c62719dad239c51f045315273b56e2a9', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::160::camsaul
--  Added 0.34.2
INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('160', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 156, '8:1441c71af662abb809cba3b3b360ce81', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::162::camsaul
--  Added 0.23.0 as a data migration; converted to Liquibase migration in 0.35.0
DROP TABLE metabase_dev.query_queryexecution;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('162', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 157, '8:c37f015ad11d77d66e09925eed605cdf', 'dropTable tableName=query_queryexecution', 'Added 0.23.0 as a data migration; converted to Liquibase migration in 0.35.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::163::camsaul
--  Added 0.35.0
ALTER TABLE metabase_dev.report_card DROP COLUMN read_permissions;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('163', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 158, '8:9ef66a82624d70738fc89807a2398ed1', 'dropColumn columnName=read_permissions, tableName=report_card', 'Added 0.35.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::164::camsaul
--  Added 0.35.0
ALTER TABLE metabase_dev.core_user ADD locale VARCHAR(5) NULL COMMENT 'Preferred ISO locale (language/country) code, e.g "en" or "en-US", for this User. Overrides site default.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('164', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 159, '8:f19470701bbb33f19f91b1199a915881', 'addColumn tableName=core_user', 'Added 0.35.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::165::sb
--  Added field_order to Table and database_position to Field
ALTER TABLE metabase_dev.metabase_field ADD database_position INT DEFAULT 0 NOT NULL;

ALTER TABLE metabase_dev.metabase_field ADD custom_position INT DEFAULT 0 NOT NULL;

ALTER TABLE metabase_dev.metabase_table ADD field_order VARCHAR(254) DEFAULT 'database' NOT NULL;

update metabase_field set database_position = id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('165', 'sb', 'migrations/000_migrations.yaml', current_timestamp(6), 160, '8:b3ae2b90db5c4264ea2ac50d304d6ad4', 'addColumn tableName=metabase_field; addColumn tableName=metabase_field; addColumn tableName=metabase_table; sql', 'Added field_order to Table and database_position to Field', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

-- [x] error free until here

--  Changeset migrations/000_migrations.yaml::166::camsaul
--  Added 0.36.0/1.35.4
-- [x] fixed for tidb
-- ALTER TABLE metabase_dev.metabase_fieldvalues MODIFY updated_at timestamp(6);

-- [x] fixed for tidb
-- ALTER TABLE metabase_dev.query_cache MODIFY updated_at timestamp(6);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('166', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 161, '8:cd87d40358297ca4a3a644f92a03c377', 'modifyDataType columnName=updated_at, tableName=metabase_fieldvalues; modifyDataType columnName=updated_at, tableName=query_cache', 'Added 0.36.0/1.35.4', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::167::walterl, camsaul
--  Added 0.36.0
drop table if exists native_query_snippet;

CREATE TABLE metabase_dev.native_query_snippet (id INT AUTO_INCREMENT NOT NULL, name VARCHAR(254) NOT NULL COMMENT 'Name of the query snippet', `description` TEXT NULL, content TEXT NOT NULL COMMENT 'Raw query snippet', creator_id INT NOT NULL, archived BIT(1) DEFAULT 0 NOT NULL, created_at timestamp(6) DEFAULT current_timestamp(6) NOT NULL, updated_at timestamp(6) DEFAULT current_timestamp(6) NOT NULL, CONSTRAINT PK_NATIVE_QUERY_SNIPPET PRIMARY KEY (id), CONSTRAINT fk_snippet_creator_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user(id) ON DELETE CASCADE, UNIQUE (name)) COMMENT='Query snippets (raw text) to be substituted in native queries' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.native_query_snippet COMMENT = 'Query snippets (raw text) to be substituted in native queries';

CREATE INDEX idx_snippet_name ON metabase_dev.native_query_snippet(name);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('167', 'walterl, camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 162, '8:f187b98459bd5473aebda7a66fbf9aff', 'sql; createTable tableName=native_query_snippet; createIndex indexName=idx_snippet_name, tableName=native_query_snippet', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::168::camsaul
--  Added 0.36.0

-- [x] fixed for tidb
-- ALTER TABLE metabase_dev.query_execution MODIFY started_at timestamp(6);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('168', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 163, '8:c4ba88582a69b4695512d5f1e114b6da', 'modifyDataType columnName=started_at, tableName=query_execution', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::169::camsaul
--  Added 0.36.0
ALTER TABLE `metabase_dev`.`metabase_table` DROP COLUMN `rows`;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('169', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 164, '8:2b97e6eaa7854e179abb9f3749f73b18', 'dropColumn columnName=rows, tableName=metabase_table', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::170::sb
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_table DROP COLUMN fields_hash;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('170', 'sb', 'migrations/000_migrations.yaml', current_timestamp(6), 165, '8:dbd6ee52b0f9195e449a6d744606b599', 'dropColumn columnName=fields_hash, tableName=metabase_table', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::171::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.native_query_snippet ADD collection_id INT NULL COMMENT 'ID of the Snippet Folder (Collection) this Snippet is in, if any';

ALTER TABLE metabase_dev.native_query_snippet ADD CONSTRAINT fk_snippet_collection_id FOREIGN KEY (collection_id) REFERENCES metabase_dev.collection (id);

CREATE INDEX idx_snippet_collection_id ON metabase_dev.native_query_snippet(collection_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('171', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 166, '8:0798080c0796e6ab3e791bff007118b8', 'addColumn tableName=native_query_snippet; createIndex indexName=idx_snippet_collection_id, tableName=native_query_snippet', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::172::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.collection ADD namespace VARCHAR(254) NULL COMMENT 'The namespace (hierachy) this Collection belongs to. NULL means the Collection is in the default namespace.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('172', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 167, '8:212f4010b504e358853fd017032f844f', 'addColumn tableName=collection', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::173::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.activity DROP FOREIGN KEY fk_activity_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('173', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 168, '8:4d32b4b7be3f4801e51aeffa5dd47649', 'dropForeignKeyConstraint baseTableName=activity, constraintName=fk_activity_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::174::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.activity ADD CONSTRAINT fk_activity_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('174', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 169, '8:66f31503ba532702e54ea531af668531', 'addForeignKeyConstraint baseTableName=activity, constraintName=fk_activity_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::175::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.card_label DROP FOREIGN KEY fk_card_label_ref_card_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('175', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 170, '8:c3ceddfca8827d73474cd9a70ea01d1c', 'dropForeignKeyConstraint baseTableName=card_label, constraintName=fk_card_label_ref_card_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::176::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.card_label ADD CONSTRAINT fk_card_label_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('176', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 171, '8:89c918faa84b7f3f5fa291d4da74414c', 'addForeignKeyConstraint baseTableName=card_label, constraintName=fk_card_label_ref_card_id, referencedTableName=report_card', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::177::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.card_label DROP FOREIGN KEY fk_card_label_ref_label_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('177', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 172, '8:d45f2198befc83de1f1f963c750607af', 'dropForeignKeyConstraint baseTableName=card_label, constraintName=fk_card_label_ref_label_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::178::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.card_label ADD CONSTRAINT fk_card_label_ref_label_id FOREIGN KEY (label_id) REFERENCES metabase_dev.label (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('178', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 173, '8:63d396999449da2d42b3d3e22f3454fa', 'addForeignKeyConstraint baseTableName=card_label, constraintName=fk_card_label_ref_label_id, referencedTableName=label', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::179::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.collection DROP FOREIGN KEY fk_collection_personal_owner_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('179', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 174, '8:2a0a7956402ef074e5d54c73ac2d5405', 'dropForeignKeyConstraint baseTableName=collection, constraintName=fk_collection_personal_owner_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::180::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.collection ADD CONSTRAINT fk_collection_personal_owner_id FOREIGN KEY (personal_owner_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('180', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 175, '8:b02225e5940a2bcca3d550f24f80123e', 'addForeignKeyConstraint baseTableName=collection, constraintName=fk_collection_personal_owner_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::181::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.collection_revision DROP FOREIGN KEY fk_collection_revision_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('181', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 176, '8:16923f06b2bbb60c6ac78a0c4b7e4d4f', 'dropForeignKeyConstraint baseTableName=collection_revision, constraintName=fk_collection_revision_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::182::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.collection_revision ADD CONSTRAINT fk_collection_revision_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('182', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 177, '8:d59d864c038c530a49056704c93f231d', 'addForeignKeyConstraint baseTableName=collection_revision, constraintName=fk_collection_revision_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::183::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.computation_job DROP FOREIGN KEY fk_computation_job_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('183', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 178, '8:c5ed9a4f44ee92af620a47c80e010a6b', 'dropForeignKeyConstraint baseTableName=computation_job, constraintName=fk_computation_job_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::184::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.computation_job ADD CONSTRAINT fk_computation_job_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('184', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 179, '8:70317e2bdaac90b9ddc33b1b93ada479', 'addForeignKeyConstraint baseTableName=computation_job, constraintName=fk_computation_job_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::185::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.computation_job_result DROP FOREIGN KEY fk_computation_result_ref_job_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('185', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 180, '8:12e7457ec2d2b1a99a3fadfc64d7b7f9', 'dropForeignKeyConstraint baseTableName=computation_job_result, constraintName=fk_computation_result_ref_job_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::186::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.computation_job_result ADD CONSTRAINT fk_computation_result_ref_job_id FOREIGN KEY (job_id) REFERENCES metabase_dev.computation_job (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('186', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 181, '8:526987d0f6b2f01d7bfc9e3179721be6', 'addForeignKeyConstraint baseTableName=computation_job_result, constraintName=fk_computation_result_ref_job_id, referencedTableName=computation_job', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::187::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.core_session DROP FOREIGN KEY fk_session_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('187', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 182, '8:3fbb75c0c491dc6628583184202b8f39', 'dropForeignKeyConstraint baseTableName=core_session, constraintName=fk_session_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::188::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.core_session ADD CONSTRAINT fk_session_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('188', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 183, '8:4dc500830cd4c5715ca8b0956e37b3d5', 'addForeignKeyConstraint baseTableName=core_session, constraintName=fk_session_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::189::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.dashboardcard_series DROP FOREIGN KEY fk_dashboardcard_series_ref_card_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('189', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 184, '8:e07396e0ee587dcf321d21cffa9eec29', 'dropForeignKeyConstraint baseTableName=dashboardcard_series, constraintName=fk_dashboardcard_series_ref_card_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::190::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.dashboardcard_series ADD CONSTRAINT fk_dashboardcard_series_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('190', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 185, '8:eded791094a16bf398896c790645c411', 'addForeignKeyConstraint baseTableName=dashboardcard_series, constraintName=fk_dashboardcard_series_ref_card_id, referencedTableName=report_card', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::191::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.dashboardcard_series DROP FOREIGN KEY fk_dashboardcard_series_ref_dashboardcard_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('191', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 186, '8:bb5b9a3d64b2e44318e159e7f1fecde2', 'dropForeignKeyConstraint baseTableName=dashboardcard_series, constraintName=fk_dashboardcard_series_ref_dashboardcard_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::192::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.dashboardcard_series ADD CONSTRAINT fk_dashboardcard_series_ref_dashboardcard_id FOREIGN KEY (dashboardcard_id) REFERENCES metabase_dev.report_dashboardcard (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('192', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 187, '8:7d96911036dec2fee64fe8ae57c131b3', 'addForeignKeyConstraint baseTableName=dashboardcard_series, constraintName=fk_dashboardcard_series_ref_dashboardcard_id, referencedTableName=report_dashboardcard', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::193::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.group_table_access_policy DROP FOREIGN KEY fk_gtap_card_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('193', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 188, '8:db171179fe094db9fee7e2e7df60fa4e', 'dropForeignKeyConstraint baseTableName=group_table_access_policy, constraintName=fk_gtap_card_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::194::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.group_table_access_policy ADD CONSTRAINT fk_gtap_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('194', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 189, '8:fccb724d7ae7606e2e7638de1791392a', 'addForeignKeyConstraint baseTableName=group_table_access_policy, constraintName=fk_gtap_card_id, referencedTableName=report_card', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::195::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_field DROP FOREIGN KEY fk_field_parent_ref_field_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('195', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 190, '8:1d720af9f917007024c91d40410bc91d', 'dropForeignKeyConstraint baseTableName=metabase_field, constraintName=fk_field_parent_ref_field_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::196::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_field ADD CONSTRAINT fk_field_parent_ref_field_id FOREIGN KEY (parent_id) REFERENCES metabase_dev.metabase_field (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('196', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 191, '8:c52f5dbf742feef12a3803bda92a425b', 'addForeignKeyConstraint baseTableName=metabase_field, constraintName=fk_field_parent_ref_field_id, referencedTableName=metabase_field', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::197::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_field DROP FOREIGN KEY fk_field_ref_table_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('197', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 192, '8:9c1c950b709050abe91cea17fd5970cc', 'dropForeignKeyConstraint baseTableName=metabase_field, constraintName=fk_field_ref_table_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::198::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_field ADD CONSTRAINT fk_field_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase_dev.metabase_table (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('198', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 193, '8:e24198ff4825a41d17ceaebd71692103', 'addForeignKeyConstraint baseTableName=metabase_field, constraintName=fk_field_ref_table_id, referencedTableName=metabase_table', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::199::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_fieldvalues DROP FOREIGN KEY fk_fieldvalues_ref_field_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('199', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 194, '8:146efae3f2938538961835fe07433ee1', 'dropForeignKeyConstraint baseTableName=metabase_fieldvalues, constraintName=fk_fieldvalues_ref_field_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::200::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_fieldvalues ADD CONSTRAINT fk_fieldvalues_ref_field_id FOREIGN KEY (field_id) REFERENCES metabase_dev.metabase_field (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('200', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 195, '8:f5e7e79cb81b8d2245663c482746c853', 'addForeignKeyConstraint baseTableName=metabase_fieldvalues, constraintName=fk_fieldvalues_ref_field_id, referencedTableName=metabase_field', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::201::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_table DROP FOREIGN KEY fk_table_ref_database_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('201', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 196, '8:2d79321a27fde6cb3c4fabdb86dc60ec', 'dropForeignKeyConstraint baseTableName=metabase_table, constraintName=fk_table_ref_database_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::202::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metabase_table ADD CONSTRAINT fk_table_ref_database_id FOREIGN KEY (db_id) REFERENCES metabase_dev.metabase_database (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('202', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 197, '8:d0cefed061c4abbf2b0a0fd2a66817cb', 'addForeignKeyConstraint baseTableName=metabase_table, constraintName=fk_table_ref_database_id, referencedTableName=metabase_database', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::203::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metric DROP FOREIGN KEY fk_metric_ref_creator_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('203', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 198, '8:28b4ec07bfbf4b86532fe9357effdb8b', 'dropForeignKeyConstraint baseTableName=metric, constraintName=fk_metric_ref_creator_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::204::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metric ADD CONSTRAINT fk_metric_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('204', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 199, '8:7195937fd2144533edfa2302ba2ae653', 'addForeignKeyConstraint baseTableName=metric, constraintName=fk_metric_ref_creator_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::205::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metric DROP FOREIGN KEY fk_metric_ref_table_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('205', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 200, '8:4b2d5f1458641dd1b9dbc5f41600be8e', 'dropForeignKeyConstraint baseTableName=metric, constraintName=fk_metric_ref_table_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::206::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metric ADD CONSTRAINT fk_metric_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase_dev.metabase_table (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('206', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 201, '8:959ef448c23aaf3acf5b69f297fe4b2f', 'addForeignKeyConstraint baseTableName=metric, constraintName=fk_metric_ref_table_id, referencedTableName=metabase_table', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::207::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metric_important_field DROP FOREIGN KEY fk_metric_important_field_metabase_field_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('207', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 202, '8:18135d674f2fe502313adb0475f5f139', 'dropForeignKeyConstraint baseTableName=metric_important_field, constraintName=fk_metric_important_field_metabase_field_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::208::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metric_important_field ADD CONSTRAINT fk_metric_important_field_metabase_field_id FOREIGN KEY (field_id) REFERENCES metabase_dev.metabase_field (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('208', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 203, '8:4c86c17a00a81dfdf35a181e3dd3b08f', 'addForeignKeyConstraint baseTableName=metric_important_field, constraintName=fk_metric_important_field_metabase_field_id, referencedTableName=metabase_field', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::209::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metric_important_field DROP FOREIGN KEY fk_metric_important_field_metric_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('209', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 204, '8:1b9c3544bf89093fc9e4f7f191fdc6df', 'dropForeignKeyConstraint baseTableName=metric_important_field, constraintName=fk_metric_important_field_metric_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::210::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.metric_important_field ADD CONSTRAINT fk_metric_important_field_metric_id FOREIGN KEY (metric_id) REFERENCES metabase_dev.metric (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('210', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 205, '8:842d166cdf7b0a29c88efdaf95c9d0bf', 'addForeignKeyConstraint baseTableName=metric_important_field, constraintName=fk_metric_important_field_metric_id, referencedTableName=metric', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::211::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.native_query_snippet DROP FOREIGN KEY fk_snippet_collection_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('211', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 206, '8:91c64815a1aefb07dd124d493bfeeea9', 'dropForeignKeyConstraint baseTableName=native_query_snippet, constraintName=fk_snippet_collection_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::212::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.native_query_snippet ADD CONSTRAINT fk_snippet_collection_id FOREIGN KEY (collection_id) REFERENCES metabase_dev.collection (id) ON DELETE SET NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('212', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 207, '8:b25064ee26b71f61906a833bc22ebbc2', 'addForeignKeyConstraint baseTableName=native_query_snippet, constraintName=fk_snippet_collection_id, referencedTableName=collection', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::213::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.permissions DROP FOREIGN KEY fk_permissions_group_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('213', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 208, '8:60a7d628e4f68ee4c85f5f298b1d9865', 'dropForeignKeyConstraint baseTableName=permissions, constraintName=fk_permissions_group_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::214::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.permissions ADD CONSTRAINT fk_permissions_group_id FOREIGN KEY (group_id) REFERENCES metabase_dev.permissions_group (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('214', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 209, '8:1c3c480313967a2d9f324a094ba25f4d', 'addForeignKeyConstraint baseTableName=permissions, constraintName=fk_permissions_group_id, referencedTableName=permissions_group', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::215::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.permissions_group_membership DROP FOREIGN KEY fk_permissions_group_group_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('215', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 210, '8:5d2c67ccead52970e9d85beb7eda48b9', 'dropForeignKeyConstraint baseTableName=permissions_group_membership, constraintName=fk_permissions_group_group_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::216::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.permissions_group_membership ADD CONSTRAINT fk_permissions_group_group_id FOREIGN KEY (group_id) REFERENCES metabase_dev.permissions_group (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('216', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 211, '8:35fcd5d48600e887188eb1b990e6cc35', 'addForeignKeyConstraint baseTableName=permissions_group_membership, constraintName=fk_permissions_group_group_id, referencedTableName=permissions_group', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::217::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.permissions_group_membership DROP FOREIGN KEY fk_permissions_group_membership_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('217', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 212, '8:da7460a35a724109ae9b5096cd18666b', 'dropForeignKeyConstraint baseTableName=permissions_group_membership, constraintName=fk_permissions_group_membership_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::218::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.permissions_group_membership ADD CONSTRAINT fk_permissions_group_membership_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('218', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 213, '8:dc04b7eb04cd870c53102cb37fd75a5f', 'addForeignKeyConstraint baseTableName=permissions_group_membership, constraintName=fk_permissions_group_membership_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::219::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.permissions_revision DROP FOREIGN KEY fk_permissions_revision_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('219', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 214, '8:02c690f34fe8803e42441f5037d33017', 'dropForeignKeyConstraint baseTableName=permissions_revision, constraintName=fk_permissions_revision_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::220::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.permissions_revision ADD CONSTRAINT fk_permissions_revision_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('220', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 215, '8:8b8447405d7b2b52358c9676d64b7651', 'addForeignKeyConstraint baseTableName=permissions_revision, constraintName=fk_permissions_revision_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::221::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse DROP FOREIGN KEY fk_pulse_collection_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('221', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 216, '8:54a4c0d8a4eda80dc81fb549a629d075', 'dropForeignKeyConstraint baseTableName=pulse, constraintName=fk_pulse_collection_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::222::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse ADD CONSTRAINT fk_pulse_collection_id FOREIGN KEY (collection_id) REFERENCES metabase_dev.collection (id) ON DELETE SET NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('222', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 217, '8:c5f22e925be3a8fd0e4f47a491f599ee', 'addForeignKeyConstraint baseTableName=pulse, constraintName=fk_pulse_collection_id, referencedTableName=collection', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::223::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse DROP FOREIGN KEY fk_pulse_ref_creator_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('223', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 218, '8:de743e384ff90a6a31a3caebe0abb775', 'dropForeignKeyConstraint baseTableName=pulse, constraintName=fk_pulse_ref_creator_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::224::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse ADD CONSTRAINT fk_pulse_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('224', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 219, '8:b8fdf9c14d7ea3131a0a6b1f1036f91a', 'addForeignKeyConstraint baseTableName=pulse, constraintName=fk_pulse_ref_creator_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::225::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_card DROP FOREIGN KEY fk_pulse_card_ref_card_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('225', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 220, '8:495a4e12cf75cac5ff54738772e6a998', 'dropForeignKeyConstraint baseTableName=pulse_card, constraintName=fk_pulse_card_ref_card_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::226::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_card ADD CONSTRAINT fk_pulse_card_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('226', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 221, '8:cf383d74bc407065c78c060203ba4560', 'addForeignKeyConstraint baseTableName=pulse_card, constraintName=fk_pulse_card_ref_card_id, referencedTableName=report_card', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::227::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_card DROP FOREIGN KEY fk_pulse_card_ref_pulse_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('227', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 222, '8:e23eaf74ab7edacfb34bd5caf05cf66f', 'dropForeignKeyConstraint baseTableName=pulse_card, constraintName=fk_pulse_card_ref_pulse_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::228::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_card ADD CONSTRAINT fk_pulse_card_ref_pulse_id FOREIGN KEY (pulse_id) REFERENCES metabase_dev.pulse (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('228', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 223, '8:d458ddb160f61e93bb69738f262de2b4', 'addForeignKeyConstraint baseTableName=pulse_card, constraintName=fk_pulse_card_ref_pulse_id, referencedTableName=pulse', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::229::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_channel DROP FOREIGN KEY fk_pulse_channel_ref_pulse_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('229', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 224, '8:1cb939d172989cb1629e9a3da768596d', 'dropForeignKeyConstraint baseTableName=pulse_channel, constraintName=fk_pulse_channel_ref_pulse_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::230::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_channel ADD CONSTRAINT fk_pulse_channel_ref_pulse_id FOREIGN KEY (pulse_id) REFERENCES metabase_dev.pulse (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('230', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 225, '8:62baea3334ac5f21feac84497f6bf643', 'addForeignKeyConstraint baseTableName=pulse_channel, constraintName=fk_pulse_channel_ref_pulse_id, referencedTableName=pulse', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::231::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_channel_recipient DROP FOREIGN KEY fk_pulse_channel_recipient_ref_pulse_channel_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('231', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 226, '8:d096a9ce70fc0b7dfbc67ee1be4c3e31', 'dropForeignKeyConstraint baseTableName=pulse_channel_recipient, constraintName=fk_pulse_channel_recipient_ref_pulse_channel_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::232::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_channel_recipient ADD CONSTRAINT fk_pulse_channel_recipient_ref_pulse_channel_id FOREIGN KEY (pulse_channel_id) REFERENCES metabase_dev.pulse_channel (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('232', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 227, '8:be2457ae1e386c9d5ec5bfa4ae681fd6', 'addForeignKeyConstraint baseTableName=pulse_channel_recipient, constraintName=fk_pulse_channel_recipient_ref_pulse_channel_id, referencedTableName=pulse_channel', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::233::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_channel_recipient DROP FOREIGN KEY fk_pulse_channel_recipient_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('233', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 228, '8:d5c018882af16093de446e025e2599b7', 'dropForeignKeyConstraint baseTableName=pulse_channel_recipient, constraintName=fk_pulse_channel_recipient_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::234::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.pulse_channel_recipient ADD CONSTRAINT fk_pulse_channel_recipient_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('234', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 229, '8:edb6ced6c353064c46fa00b54e187aef', 'addForeignKeyConstraint baseTableName=pulse_channel_recipient, constraintName=fk_pulse_channel_recipient_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::235::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card DROP FOREIGN KEY fk_card_collection_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('235', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 230, '8:550c64e41e55233d52ac3ef24d664be1', 'dropForeignKeyConstraint baseTableName=report_card, constraintName=fk_card_collection_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::236::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_card_collection_id FOREIGN KEY (collection_id) REFERENCES metabase_dev.collection (id) ON DELETE SET NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('236', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 231, '8:04300b298b663fc2a2f3a324d1051c3c', 'addForeignKeyConstraint baseTableName=report_card, constraintName=fk_card_collection_id, referencedTableName=collection', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::237::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card DROP FOREIGN KEY fk_card_made_public_by_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('237', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 232, '8:227a9133cdff9f1b60d8af53688ab12e', 'dropForeignKeyConstraint baseTableName=report_card, constraintName=fk_card_made_public_by_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::238::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_card_made_public_by_id FOREIGN KEY (made_public_by_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('238', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 233, '8:7000766ddca2c914ac517611e7d86549', 'addForeignKeyConstraint baseTableName=report_card, constraintName=fk_card_made_public_by_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::239::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card DROP FOREIGN KEY fk_card_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('239', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 234, '8:672f4972653f70464982008a7abea3e1', 'dropForeignKeyConstraint baseTableName=report_card, constraintName=fk_card_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::240::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_card_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('240', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 235, '8:165b07c8ceb004097c83ee1b689164e4', 'addForeignKeyConstraint baseTableName=report_card, constraintName=fk_card_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::241::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card DROP FOREIGN KEY fk_report_card_ref_database_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('241', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 236, '8:b0a9e3d801e64e0a66c3190e458c01ae', 'dropForeignKeyConstraint baseTableName=report_card, constraintName=fk_report_card_ref_database_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::242::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_report_card_ref_database_id FOREIGN KEY (database_id) REFERENCES metabase_dev.metabase_database (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('242', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 237, '8:bf10f944715f87c3ad0dd7472d84df62', 'addForeignKeyConstraint baseTableName=report_card, constraintName=fk_report_card_ref_database_id, referencedTableName=metabase_database', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::243::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card DROP FOREIGN KEY fk_report_card_ref_table_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('243', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 238, '8:cba5d2bfb36e13c60d82cc6cca659b61', 'dropForeignKeyConstraint baseTableName=report_card, constraintName=fk_report_card_ref_table_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::244::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_card ADD CONSTRAINT fk_report_card_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase_dev.metabase_table (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('244', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 239, '8:4d40104eaa47d01981644462ef56f369', 'addForeignKeyConstraint baseTableName=report_card, constraintName=fk_report_card_ref_table_id, referencedTableName=metabase_table', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::245::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_cardfavorite DROP FOREIGN KEY fk_cardfavorite_ref_card_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('245', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 240, '8:a8f9206dadfe23662d547035f71e3846', 'dropForeignKeyConstraint baseTableName=report_cardfavorite, constraintName=fk_cardfavorite_ref_card_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::246::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_cardfavorite ADD CONSTRAINT fk_cardfavorite_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('246', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 241, '8:e5db34b9db22254f7445fd65ecf45356', 'addForeignKeyConstraint baseTableName=report_cardfavorite, constraintName=fk_cardfavorite_ref_card_id, referencedTableName=report_card', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::247::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_cardfavorite DROP FOREIGN KEY fk_cardfavorite_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('247', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 242, '8:76de7337a12a5ef42dcbb9274bd2d70f', 'dropForeignKeyConstraint baseTableName=report_cardfavorite, constraintName=fk_cardfavorite_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::248::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_cardfavorite ADD CONSTRAINT fk_cardfavorite_ref_user_id FOREIGN KEY (owner_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('248', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 243, '8:0640fb00a090cbe5dc545afbe0d25811', 'addForeignKeyConstraint baseTableName=report_cardfavorite, constraintName=fk_cardfavorite_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::249::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboard DROP FOREIGN KEY fk_dashboard_collection_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('249', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 244, '8:16ef5909a72ac4779427e432b3b3ce18', 'dropForeignKeyConstraint baseTableName=report_dashboard, constraintName=fk_dashboard_collection_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::250::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboard ADD CONSTRAINT fk_dashboard_collection_id FOREIGN KEY (collection_id) REFERENCES metabase_dev.collection (id) ON DELETE SET NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('250', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 245, '8:2e80ebe19816b7bde99050638772cf99', 'addForeignKeyConstraint baseTableName=report_dashboard, constraintName=fk_dashboard_collection_id, referencedTableName=collection', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::251::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboard DROP FOREIGN KEY fk_dashboard_made_public_by_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('251', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 246, '8:c12aa099f293b1e3d71da5e3edb3c45a', 'dropForeignKeyConstraint baseTableName=report_dashboard, constraintName=fk_dashboard_made_public_by_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::252::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboard ADD CONSTRAINT fk_dashboard_made_public_by_id FOREIGN KEY (made_public_by_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('252', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 247, '8:26b16d4d0cf7a77c1d687f49b029f421', 'addForeignKeyConstraint baseTableName=report_dashboard, constraintName=fk_dashboard_made_public_by_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::253::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboard DROP FOREIGN KEY fk_dashboard_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('253', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 248, '8:bbf118edaa88a8ad486ec0d6965504b6', 'dropForeignKeyConstraint baseTableName=report_dashboard, constraintName=fk_dashboard_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::254::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboard ADD CONSTRAINT fk_dashboard_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('254', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 249, '8:7fc35d78c63f41eb4dbd23cfd1505f0b', 'addForeignKeyConstraint baseTableName=report_dashboard, constraintName=fk_dashboard_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::255::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboardcard DROP FOREIGN KEY fk_dashboardcard_ref_card_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('255', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 250, '8:f6564a7516ace55104a3173eebf4c629', 'dropForeignKeyConstraint baseTableName=report_dashboardcard, constraintName=fk_dashboardcard_ref_card_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::256::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboardcard ADD CONSTRAINT fk_dashboardcard_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase_dev.report_card (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('256', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 251, '8:61db9be3b4dd7ed1e9d01a7254e87544', 'addForeignKeyConstraint baseTableName=report_dashboardcard, constraintName=fk_dashboardcard_ref_card_id, referencedTableName=report_card', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::257::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboardcard DROP FOREIGN KEY fk_dashboardcard_ref_dashboard_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('257', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 252, '8:c8b51dc7ba4da9f7995a0b0c17fadad2', 'dropForeignKeyConstraint baseTableName=report_dashboardcard, constraintName=fk_dashboardcard_ref_dashboard_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::258::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.report_dashboardcard ADD CONSTRAINT fk_dashboardcard_ref_dashboard_id FOREIGN KEY (dashboard_id) REFERENCES metabase_dev.report_dashboard (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('258', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 253, '8:58974c6ad8aee63f09e6e48b1a78c267', 'addForeignKeyConstraint baseTableName=report_dashboardcard, constraintName=fk_dashboardcard_ref_dashboard_id, referencedTableName=report_dashboard', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::259::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.revision DROP FOREIGN KEY fk_revision_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('259', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 254, '8:be4a52feb3b12e655c0bbd34477749b0', 'dropForeignKeyConstraint baseTableName=revision, constraintName=fk_revision_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::260::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.revision ADD CONSTRAINT fk_revision_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('260', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 255, '8:4b370f9c9073a6f8f585aab713c57f47', 'addForeignKeyConstraint baseTableName=revision, constraintName=fk_revision_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::261::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.segment DROP FOREIGN KEY fk_segment_ref_creator_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('261', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 256, '8:173fe552fdf72fdb4efbc01a6ac4f7ad', 'dropForeignKeyConstraint baseTableName=segment, constraintName=fk_segment_ref_creator_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::262::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.segment ADD CONSTRAINT fk_segment_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('262', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 257, '8:50927b8b1d1809f32c11d2e649dbcb94', 'addForeignKeyConstraint baseTableName=segment, constraintName=fk_segment_ref_creator_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::263::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.segment DROP FOREIGN KEY fk_segment_ref_table_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('263', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 258, '8:0b10c8664506917cc50359e9634c121c', 'dropForeignKeyConstraint baseTableName=segment, constraintName=fk_segment_ref_table_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::264::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.segment ADD CONSTRAINT fk_segment_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase_dev.metabase_table (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('264', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 259, '8:b132aedf6fbdcc5d956a2d3a154cc035', 'addForeignKeyConstraint baseTableName=segment, constraintName=fk_segment_ref_table_id, referencedTableName=metabase_table', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::265::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.view_log DROP FOREIGN KEY fk_view_log_ref_user_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('265', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 260, '8:2e339ecb05463b3765f9bb266bd28297', 'dropForeignKeyConstraint baseTableName=view_log, constraintName=fk_view_log_ref_user_id', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::266::camsaul
--  Added 0.36.0
ALTER TABLE metabase_dev.view_log ADD CONSTRAINT fk_view_log_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('266', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 261, '8:31506e118764f5e520f755f26c696bb8', 'addForeignKeyConstraint baseTableName=view_log, constraintName=fk_view_log_ref_user_id, referencedTableName=core_user', 'Added 0.36.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::268::rlotun
--  Added 0.37.0
-- [x] fixed for tidb by addedin additional pair of brackets 
-- see https://docs.pingcap.com/tidb/stable/sql-statement-create-index
CREATE INDEX idx_lower_email ON metabase_dev.core_user ( (lower(email)) );

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('268', 'rlotun', 'migrations/000_migrations.yaml', current_timestamp(6), 262, '8:9da2f706a7cd42b5101601e0106fa929', 'createIndex indexName=idx_lower_email, tableName=core_user', 'Added 0.37.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::269::rlotun
--  Added 0.37.0
UPDATE core_user SET email = lower(email) WHERE lower(email) NOT IN (SELECT * FROM (SELECT lower(email) FROM core_user GROUP BY lower(email) HAVING count(email) > 1) as e);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('269', 'rlotun', 'migrations/000_migrations.yaml', current_timestamp(6), 263, '8:215609ca9dce2181687b4fa65e7351ba', 'sql', 'Added 0.37.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::270::rlotun
--  Added 0.37.0

-- [x] disabled for tidb, which does NOT support EXTENSION
-- CREATE EXTENSION IF NOT EXISTS citext;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('270', 'rlotun', 'migrations/000_migrations.yaml', current_timestamp(6), 264, '8:17001a192ba1df02104cc0d15569cbe5', 'sql', 'Added 0.37.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::271::rlotun
--  Added 0.37.0

-- [x] disabled for tidb
-- ALTER TABLE metabase_dev.core_user MODIFY email CITEXT;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('271', 'rlotun', 'migrations/000_migrations.yaml', current_timestamp(6), 265, '8:ce8ddb253a303d4f8924ff5a187080c0', 'modifyDataType columnName=email, tableName=core_user', 'Added 0.37.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::272::rlotun
--  Added 0.37.0

-- [x] disabled for tidb, which does not support VARCHAR_IGNORECASE
-- ALTER TABLE metabase_dev.core_user MODIFY email VARCHAR_IGNORECASE(254);


INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('272', 'rlotun', 'migrations/000_migrations.yaml', current_timestamp(6), 266, '8:54ad09ee0c67d58e78ccafe9b1499379', 'modifyDataType columnName=email, tableName=core_user', 'Added 0.37.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::273::camsaul
--  Added 0.37.1
ALTER TABLE metabase_dev.core_user ALTER is_superuser SET DEFAULT 0;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('273', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 267, '8:5348576bb9852f6f947e1aa39cd1626f', 'addDefaultValue columnName=is_superuser, tableName=core_user', 'Added 0.37.1', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::274::camsaul
--  Added 0.37.1
ALTER TABLE metabase_dev.core_user ALTER is_active SET DEFAULT 1;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('274', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 268, '8:11a8a84b9ba7634aeda625ff3f487d22', 'addDefaultValue columnName=is_active, tableName=core_user', 'Added 0.37.1', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::275::dpsutton
--  Added 0.38.0 refingerprint to Database
ALTER TABLE metabase_dev.metabase_database ADD refingerprint BIT(1) NULL COMMENT 'Whether or not to enable periodic refingerprinting for this Database.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('275', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 269, '8:447d9e294f59dd1058940defec7e0f40', 'addColumn tableName=metabase_database', 'Added 0.38.0 refingerprint to Database', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::276::robroland
--  Added 0.38.0 - Dashboard subscriptions
ALTER TABLE metabase_dev.pulse_card ADD dashboard_card_id INT NULL COMMENT 'If this Pulse is a Dashboard subscription, the ID of the DashboardCard that corresponds to this PulseCard.';

ALTER TABLE metabase_dev.pulse_card ADD CONSTRAINT fk_pulse_card_ref_pulse_card_id FOREIGN KEY (dashboard_card_id) REFERENCES metabase_dev.report_dashboardcard (id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('276', 'robroland', 'migrations/000_migrations.yaml', current_timestamp(6), 270, '8:59dd1fb0732c7a9b78bce896c0cff3c0', 'addColumn tableName=pulse_card', 'Added 0.38.0 - Dashboard subscriptions', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::277::tsmacdonald
--  Added 0.38.0 - Dashboard subscriptions
ALTER TABLE metabase_dev.pulse_card DROP FOREIGN KEY fk_pulse_card_ref_pulse_card_id;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('277', 'tsmacdonald', 'migrations/000_migrations.yaml', current_timestamp(6), 271, '8:367180f0820b72ad2c60212e67ae53e7', 'dropForeignKeyConstraint baseTableName=pulse_card, constraintName=fk_pulse_card_ref_pulse_card_id', 'Added 0.38.0 - Dashboard subscriptions', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::278::tsmacdonald
--  Added 0.38.0 - Dashboard subscrptions
ALTER TABLE metabase_dev.pulse_card ADD CONSTRAINT fk_pulse_card_ref_pulse_card_id FOREIGN KEY (dashboard_card_id) REFERENCES metabase_dev.report_dashboardcard (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('278', 'tsmacdonald', 'migrations/000_migrations.yaml', current_timestamp(6), 272, '8:fc4fb1c1e3344374edd7b9f1f0d34c89', 'addForeignKeyConstraint baseTableName=pulse_card, constraintName=fk_pulse_card_ref_pulse_card_id, referencedTableName=report_dashboardcard', 'Added 0.38.0 - Dashboard subscrptions', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::279::camsaul
--  Added 0.38.0 - Dashboard subscriptions
ALTER TABLE metabase_dev.pulse ADD dashboard_id INT NULL COMMENT 'ID of the Dashboard if this Pulse is a Dashboard Subscription.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('279', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 273, '8:63dfccd51b62b939da71fe4435f58679', 'addColumn tableName=pulse', 'Added 0.38.0 - Dashboard subscriptions', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::280::camsaul
--  Added 0.38.0 - Dashboard subscriptions
ALTER TABLE metabase_dev.pulse ADD CONSTRAINT fk_pulse_ref_dashboard_id FOREIGN KEY (dashboard_id) REFERENCES metabase_dev.report_dashboard (id) ON DELETE CASCADE;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('280', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 274, '8:ae966ee1e40f20ea438daba954a8c2a6', 'addForeignKeyConstraint baseTableName=pulse, constraintName=fk_pulse_ref_dashboard_id, referencedTableName=report_dashboard', 'Added 0.38.0 - Dashboard subscriptions', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::281::dpsutton
--  Added 0.39 - Semantic type system - rename special_type
ALTER TABLE metabase_dev.metabase_field CHANGE special_type semantic_type VARCHAR(255);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('281', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 275, '8:3039286581c58eee7cca9c25fdf6d792', 'renameColumn newColumnName=semantic_type, oldColumnName=special_type, tableName=metabase_field', 'Added 0.39 - Semantic type system - rename special_type', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::282::camsaul
--  Added 0.39.0

-- [x] commented out for tidb
--ALTER TABLE task_history
--MODIFY started_at timestamp(6) DEFAULT current_timestamp(6) NOT NULL;

-- [x] fixed for tidb
ALTER TABLE task_history DROP `started_at`;
ALTER TABLE task_history ADD COLUMN `started_at` timestamp(6) DEFAULT current_timestamp(6) NOT NULL AFTER db_id;


INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('282', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 276, '8:d4b8566ee11d9f8a3d6c8c9539f6526d', 'sql; sql; sql', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::283::camsaul
--  Added 0.39.0

-- [x] commented out for tidb
--ALTER TABLE task_history
--MODIFY ended_at timestamp(6) DEFAULT current_timestamp(6) NOT NULL;

-- [x] fixed for tidb
ALTER TABLE task_history DROP `ended_at`;
ALTER TABLE task_history ADD COLUMN `ended_at` timestamp(6) DEFAULT current_timestamp(6) NOT NULL AFTER started_at;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('283', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 277, '8:2220e1b1cdb57212820b96fa3107f7c3', 'sql; sql; sql', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::284::dpsutton
--  Added 0.39 - Semantic type system - add effective type
ALTER TABLE metabase_dev.metabase_field ADD effective_type VARCHAR(255) NULL COMMENT 'The effective type of the field after any coercions.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('284', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 278, '8:c7dc9a60bcaf9b2ffcbaabd650c959b2', 'addColumn tableName=metabase_field', 'Added 0.39 - Semantic type system - add effective type', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::285::dpsutton
--  Added 0.39 - Semantic type system - add coercion column
ALTER TABLE metabase_dev.metabase_field ADD coercion_strategy VARCHAR(255) NULL COMMENT 'A strategy to coerce the base_type into the effective_type.';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('285', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 279, '8:cf7d6f5135fa3397a7dc67509d1c286e', 'addColumn tableName=metabase_field', 'Added 0.39 - Semantic type system - add coercion column', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::286::dpsutton
--  Added 0.39 - Semantic type system - set effective_type default
UPDATE metabase_field set effective_type = base_type;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('286', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 280, '8:bce9ab328411f05d8c52d64bff5bded0', 'sql', 'Added 0.39 - Semantic type system - set effective_type default', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::287::dpsutton
--  Added 0.39 - Semantic type system - migrate ISO8601 strings
UPDATE metabase_field SET effective_type    = (CASE semantic_type
                           WHEN 'type/ISO8601DateTimeString' THEN 'type/DateTime'
                           WHEN 'type/ISO8601TimeString'     THEN 'type/Time'
                           WHEN 'type/ISO8601DateString'     THEN 'type/Date'
                         END),
    coercion_strategy = (CASE semantic_type
                          WHEN 'type/ISO8601DateTimeString' THEN 'Coercion/ISO8601->DateTime'
                          WHEN 'type/ISO8601TimeString'     THEN 'Coercion/ISO8601->Time'
                          WHEN 'type/ISO8601DateString'     THEN 'Coercion/ISO8601->Date'
                         END)
WHERE semantic_type IN ('type/ISO8601DateTimeString',
                        'type/ISO8601TimeString',
                        'type/ISO8601DateString');

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('287', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 281, '8:0679eedae767a8648383aac2f923e413', 'sql', 'Added 0.39 - Semantic type system - migrate ISO8601 strings', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::288::dpsutton
--  Added 0.39 - Semantic type system - migrate unix timestamps
UPDATE metabase_field set effective_type    = 'type/Instant',
    coercion_strategy = (case semantic_type
                          WHEN 'type/UNIXTimestampSeconds'      THEN 'Coercion/UNIXSeconds->DateTime'
                          WHEN 'timestamp_seconds'              THEN 'Coercion/UNIXSeconds->DateTime'
                          WHEN 'type/UNIXTimestampMilliSeconds' THEN 'Coercion/UNIXMilliSeconds->DateTime'
                          WHEN 'timestamp_milliseconds'         THEN 'Coercion/UNIXMilliSeconds->DateTime'
                          WHEN 'type/UNIXTimestampMicroSeconds' THEN 'Coercion/UNIXMicroSeconds->DateTime'
                         END)
WHERE semantic_type IN ('type/UNIXTimestampSeconds',
                        'type/UNIXTimestampMilliSeconds',
                        'type/UNIXTimestampMicroSeconds',
                        'timestamp_seconds',
                        'timestamp_milliseconds');

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('288', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 282, '8:943c6dd0c9339729fefcee9207227849', 'sql', 'Added 0.39 - Semantic type system - migrate unix timestamps', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::289::dpsutton
--  Added 0.39 - Semantic type system - migrate unix timestamps (corrects typo- seconds was migrated correctly, not millis and micros)
UPDATE metabase_field set effective_type    = 'type/Instant',
    coercion_strategy = (case semantic_type
                          WHEN 'type/UNIXTimestampMilliseconds' THEN 'Coercion/UNIXMilliSeconds->DateTime'
                          WHEN 'type/UNIXTimestampMicroseconds' THEN 'Coercion/UNIXMicroSeconds->DateTime'
                         END)
WHERE semantic_type IN ('type/UNIXTimestampMilliseconds',
                        'type/UNIXTimestampMicroseconds');

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('289', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 283, '8:9f7f2e9bbf3236f204c644dc8ea7abef', 'sql', 'Added 0.39 - Semantic type system - migrate unix timestamps (corrects typo- seconds was migrated correctly, not millis and micros)', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::290::dpsutton
--  Added 0.39 - Semantic type system - Clobber semantic_type where there was a coercion
UPDATE metabase_field set semantic_type = null where coercion_strategy is not null;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('290', 'dpsutton', 'migrations/000_migrations.yaml', current_timestamp(6), 284, '8:98ea7254bc843302db4afe493c4c75e6', 'sql', 'Added 0.39 - Semantic type system - Clobber semantic_type where there was a coercion', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::291::camsaul
--  Added 0.39.0
CREATE TABLE metabase_dev.login_history (id INT AUTO_INCREMENT NOT NULL, timestamp timestamp(6) DEFAULT current_timestamp(6) NOT NULL COMMENT 'When this login occurred.', user_id INT NOT NULL COMMENT 'ID of the User that logged in.', session_id VARCHAR(254) NULL COMMENT 'ID of the Session created by this login if one is currently active. NULL if Session is no longer active.', device_id CHAR(36) NOT NULL COMMENT 'Cookie-based unique identifier for the device/browser the user logged in from.', device_description TEXT NOT NULL COMMENT 'Description of the device that login happened from, for example a user-agent string, but this might be something different if we support alternative auth mechanisms in the future.', ip_address TEXT NOT NULL COMMENT 'IP address of the device that login happened from, so we can geocode it and determine approximate location.', CONSTRAINT PK_LOGIN_HISTORY PRIMARY KEY (id), CONSTRAINT fk_login_history_user_id FOREIGN KEY (user_id) REFERENCES metabase_dev.core_user(id) ON DELETE CASCADE) COMMENT='Keeps track of various logins for different users and additional info such as location and device' ENGINE InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE metabase_dev.login_history COMMENT = 'Keeps track of various logins for different users and additional info such as location and device';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('291', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 285, '8:a601033e358289e7e2cf21d96e0d51bc', 'createTable tableName=login_history', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::292::camsaul
--  Added 0.39.0
CREATE INDEX idx_user_id ON metabase_dev.login_history(user_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('292', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 286, '8:e4ac005f4d4e73d5e1176bcbde510d6e', 'createIndex indexName=idx_user_id, tableName=login_history', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::293::camsaul
--  Added 0.39.0
ALTER TABLE metabase_dev.login_history ADD CONSTRAINT fk_login_history_session_id FOREIGN KEY (session_id) REFERENCES metabase_dev.core_session (id) ON DELETE SET NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('293', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 287, '8:7ba1bd887f8ae11a186b0e3fe69ab3e0', 'addForeignKeyConstraint baseTableName=login_history, constraintName=fk_login_history_session_id, referencedTableName=core_session', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::294::camsaul
--  Added 0.39.0
CREATE INDEX idx_session_id ON metabase_dev.login_history(session_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('294', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 288, '8:88d7a9c88866af42b9f0e7c1df9c2fd0', 'createIndex indexName=idx_session_id, tableName=login_history', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::295::camsaul
--  Added 0.39.0
CREATE INDEX idx_timestamp ON metabase_dev.login_history(timestamp);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('295', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 289, '8:501e85a50912649416ec22b2871af087', 'createIndex indexName=idx_timestamp, tableName=login_history', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::296::camsaul
--  Added 0.39.0
CREATE INDEX idx_user_id_device_id ON metabase_dev.login_history(session_id, device_id);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('296', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 290, '8:f9eb8b15c2c889334f3848a6bb4ebdb4', 'createIndex indexName=idx_user_id_device_id, tableName=login_history', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::297::camsaul
--  Added 0.39.0
CREATE INDEX idx_user_id_timestamp ON metabase_dev.login_history(user_id, timestamp);

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('297', 'camsaul', 'migrations/000_migrations.yaml', current_timestamp(6), 291, '8:06c180e4c8361f7550f6f4deaf9fc855', 'createIndex indexName=idx_user_id_timestamp, tableName=login_history', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::298::tsmacdonald
--  Added 0.39.0
ALTER TABLE metabase_dev.pulse ADD parameters TEXT NULL COMMENT 'Let dashboard subscriptions have their own filters';

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('298', 'tsmacdonald', 'migrations/000_migrations.yaml', current_timestamp(6), 292, '8:3c73f77d8d939d14320964a35aeaad5e', 'addColumn tableName=pulse', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Changeset migrations/000_migrations.yaml::299::tsmacdonald
--  Added 0.39.0
UPDATE metabase_dev.pulse SET parameters = '[]' WHERE parameters IS NULL;

ALTER TABLE metabase_dev.pulse MODIFY parameters TEXT NOT NULL;

INSERT INTO metabase_dev.DATABASECHANGELOG (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, `DESCRIPTION`, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('299', 'tsmacdonald', 'migrations/000_migrations.yaml', current_timestamp(6), 293, '8:ee3a96e30b07f37240a933e2f0710082', 'addNotNullConstraint columnName=parameters, tableName=pulse', 'Added 0.39.0', 'EXECUTED', NULL, NULL, '3.6.3', '9771178925');

--  Release Database Lock
UPDATE metabase_dev.DATABASECHANGELOGLOCK SET `LOCKED` = 0, LOCKEDBY = NULL, LOCKGRANTED = NULL WHERE ID = 1;



