-- ============================================ --
-- |        Created on January 2023           | --
-- |  Copyrigth (c) 2023 ISRAEL SANCHEZ       | --
-- |          All rights reserved             | --
-- ============================================ --
-- | Query to insert the default values on DB | --
-- ============================================ --

INSERT INTO bamx.category (cat_id, cat_name) VALUES (0, 'Bronce');
INSERT INTO bamx.category (cat_id, cat_name) VALUES (0, 'Plata');
INSERT INTO bamx.category (cat_id, cat_name) VALUES (0, 'Oro');
INSERT INTO bamx.category (cat_id, cat_name) VALUES (0, 'Diamante');

INSERT INTO bamx.type (type_id, type_name)  VALUES (0, 'Recurrente'),
                                                   (0, 'Por temporada'),
                                                   (0, 'Compra'),
                                                   (0, 'Prospecto');