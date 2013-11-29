-- Function: fn_borrar_productos(categoria character varying)

-- DROP FUNCTION fn_borrar_productos(categoria character varying)

CREATE OR REPLACE FUNCTION fn_borrar_productos(categoria character varying)
  RETURNS character varying AS
$BODY$
DECLARE
	prows      record; -- categorias

BEGIN

	FOR  prows IN ( SELECT * FROM products WHERE category = categoria) LOOP

		DELETE FROM  products_cat 
			WHERE product = prows.id;

		DELETE FROM  stockdiary 
			WHERE product = prows.id;

	END LOOP;
	
	
	DELETE FROM products 
		WHERE category = categoria;

	DELETE FROM categories
		WHERE id = categoria;

	RETURN 'FINISH';

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION fn_borrar_productos(character varying)
  OWNER TO postgres;
