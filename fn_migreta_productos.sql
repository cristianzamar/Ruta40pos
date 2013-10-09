-- Function: fn_migreta_productos(numeric)

-- DROP FUNCTION fn_migreta_productos(numeric);

CREATE OR REPLACE FUNCTION fn_migreta_productos(borrar numeric)
  RETURNS numeric AS
$BODY$

 DECLARE
	v_retorno	NUMERIC;
	v_categoria     character varying;
	crows      record; -- categorias
   	prows      record; -- productos
        drows      record;
   	arows      record; -- atributos
        vrows      record; -- valores de los atributos
	_id_producto numeric;
	_id_stock numeric;
	_id_atributo  numeric;
	_id_atributoset numeric;
	_id_atributoset_N numeric;
	_id_attributeuse numeric;
        _id_attributesetinstance numeric;
        _id_attributeinstance numeric;
	_id_talle numeric;
	_id_color numeric;
	_id_talle_n numeric;
	_id_color_n numeric;
	_id_atribute_value numeric;
        _id_temp_asetins numeric;
	v_cant_vendido numeric;
	v_cant_novendido numeric;
        
 BEGIN


if borrar = 1 then 
 
   --BORRADO valores de los atributos
      delete from attributeuse; 
      delete from attributeinstance ;
      delete from attributevalue;
      delete from attribute   ;
      

    -- borrado de productos
	delete from  products_cat;

	delete from  "stockdiary";
	delete from  "stockcurrent";
	delete from  "stocklevel";
	delete from  "ticketlines";
	delete from   products;
	delete from   attributeset;
	delete from   attributesetinstance;
	delete from   categories;
	 
end if;





     v_retorno := 0;
     
     --categorias
   
    FOR  crows IN ( SELECT  rtrim("PROV")  as cate FROM "LISTAS" WHERE "PROV" IS NOT NULL  GROUP BY rtrim("PROV") order by cate) LOOP
        v_retorno = v_retorno + 1;

        INSERT INTO categories(
              id,name  )
          VALUES (v_retorno, crows.cate );
 
    END LOOP;
   
   

     v_retorno = 0;
	_id_atributoset = 0;
	_id_atributoset_N = 0;
	_id_atributo= 0;
	_id_atribute_value = 0;
	_id_attributeuse   =0;  
	_id_attributesetinstance = 0;
	_id_attributeinstance = 0;
    
   FOR  arows IN (select "C" as atributoset from  "LISTAS" group by "C") LOOP
            
             _id_atributoset 	=   _id_atributoset + 1;
             _id_atributo    	=   _id_atributo  + 1;  
             _id_attributeuse   =   _id_attributeuse + 1;
             
               -- CONJUNTO DE ATRIBUTOS
		INSERT INTO attributeset(
			    id, name)
		    VALUES ( _id_atributoset , 'Atributos de ' || arows.atributoset  );


                     INSERT INTO attribute(id, name)
			VALUES (_id_atributo , 'Talle de ' ||   arows.atributoset );

                          _id_talle = _id_atributo;
                                                    
			INSERT INTO attributeuse(
		       id, attributeset_id, attribute_id )
			  VALUES (  _id_attributeuse  ,  _id_atributoset , _id_atributo );
			 
			 _id_atributo =   _id_atributo + 1;
                         _id_color = _id_atributo ;

                         
			INSERT INTO attribute(id, name)
			VALUES (_id_atributo , 'Color de ' ||   arows.atributoset );

			_id_attributeuse = _id_attributeuse + 1;
			
		       INSERT INTO attributeuse(
		       id, attributeset_id, attribute_id )
			  VALUES (  _id_attributeuse  ,  _id_atributoset ,_id_atributo );

         

	 FOR drows IN (select  DISTINCT(UPPER(TRIM("TALLE"))) as TALLE  from  "LISTAS"  WHERE  "TALLE" is not null  and "C" = arows.atributoset) LOOP

	       _id_atribute_value =  _id_atribute_value +  1;
	       
		 INSERT INTO attributevalue(
			    id, attribute_id, value)
		    VALUES (_id_atribute_value, _id_talle, drows.TALLE);
 			
	 END LOOP;

	  FOR drows IN (select  DISTINCT(UPPER(TRIM("COLOR"))) as  COLOR from  "LISTAS"  WHERE   "COLOR" is not null and "C" = arows.atributoset) LOOP

                 _id_atribute_value =   _id_atribute_value  +  1;
     
	    		 INSERT INTO attributevalue(
			    id, attribute_id, value)
		    VALUES (_id_atribute_value  , _id_color, drows.COLOR);
			
	 END LOOP;
	 
		
   END LOOP;

   
     _id_stock := 0 ;
  
  for  prows IN ( SELECT   "codcombi"  as codcombi,"C" as C,"DESCRIPCION" as DESCRIPCION,
                            "º" AS   preciocompra, "PL"  AS PL , 
                            '<html>' || "DESCRIPCION" || ' - ' || UPPER(TRIM("TALLE")) || ', ' || UPPER(TRIM("COLOR")) AS display,  
                             "PROV"  as PROV,1  as cantidad,"VENDIDO/NO VENDIDO" as fechaventa , "FECHA COMPRA" as fechacompra,
                             UPPER(TRIM("TALLE")) as TALLE,UPPER(TRIM("COLOR"))as COLOR 
                      FROM "LISTAS"
                   ) LOOP

           v_retorno = v_retorno + 1;
          
          
         BEGIN
	         _id_atributoset := (SELECT id FROM "attributeset"  where rtrim(name)  ilike  rtrim('Atributos de ' ||  prows.C   ));
                     v_categoria := (SELECT id FROM categories  where rtrim(name)  ilike  rtrim(prows.PROV)  );     
	            
            INSERT INTO products(
		id, reference, code,   name, pricebuy, pricesell, category, 
		taxcat, attributeset_id,  iscom, 
		isscale, iskitchen, printkb, sendstatus, isservice, display )
            VALUES (v_retorno, coalesce( prows.codcombi,' '), coalesce(prows.codcombi,' '), prows.descripcion || ' - ' || trim(coalesce(prows.TALLE,'') || ', ' || coalesce(prows.COLOR,'')) , coalesce(cast(prows.preciocompra as numeric),0),coalesce(cast(prows.PL as numeric),0),v_categoria, '000', 
		_id_atributoset ,  FALSE, FALSE, 
            FALSE, FALSE, FALSE, FALSE,prows.display  );
            
	  EXCEPTION

	     WHEN unique_violation THEN

		INSERT INTO products(
		id, reference, code,   name, pricebuy, pricesell, category, 
		taxcat, attributeset_id,  iscom, 
		isscale, iskitchen, printkb, sendstatus, isservice, display )
		VALUES (v_retorno, coalesce( prows.codcombi,' ') || 'BIS' , coalesce(prows.codcombi,' ') || 'BIS', prows.descripcion || ' - ' || trim(prows.TALLE || ', ' || prows.COLOR), coalesce(cast(prows.preciocompra as numeric),0),coalesce(cast(prows.PL as numeric),0),v_categoria, '000', 
		 _id_atributoset,  FALSE, FALSE, 
		FALSE, FALSE, FALSE, FALSE,prows.display  );

          
	     WHEN OTHERS THEN	      

		 RAISE EXCEPTION ' El error fue: %. Producto %. categoria %' ,SQLERRM,prows.descripcion,prows.C;
	END;
 

	     _id_producto  := v_retorno; 
 

            IF   prows.fechaventa IS  NULL THEN 
		v_cant_novendido := 1;
            END IF;
          
               
                    _id_stock := _id_stock + 1;
                    _id_attributeinstance  :=  _id_attributeinstance  + 1;
                    _id_atributoset_N := (SELECT attributeset_id 
                                            FROM "products" as  p  
                                           WHERE p.id  =  cast( _id_producto as text )); 


                    --SOLO SI NO EXISTE 

                   _id_temp_asetins := (SELECT COALESCE(MAX(id) ,'0')
                                                   FROM attributesetinstance  
                                                  WHERE attributeset_id = cast( _id_atributoset_N as text) 
                                                    AND trim(description) = trim(prows.TALLE || ', ' || prows.COLOR));

                    if _id_temp_asetins = 0 then
                    
                       _id_attributesetinstance := _id_attributesetinstance + 1;

                      	INSERT INTO attributesetinstance(id, attributeset_id, description)
			    VALUES (_id_attributesetinstance,_id_atributoset_N, prows.TALLE || ', ' || prows.COLOR);

                         _id_temp_asetins = _id_attributesetinstance;
                      
                    end if;
                    
                     


			 _id_talle_n :=(SELECT id 
					 FROM attribute where name = 'Talle de ' || prows.c);


			 _id_color_n :=(SELECT id 
					 FROM attribute where name = 'Color de ' || prows.c);


			  _id_attributeinstance := _id_attributeinstance + 1;
			 


			    INSERT INTO attributeinstance(
			    id, attributesetinstance_id, attribute_id, value)
		    VALUES ( _id_attributeinstance ,  _id_temp_asetins ,_id_talle_n, prows.TALLE);

                         _id_attributeinstance := _id_attributeinstance + 1;
  
			    INSERT INTO attributeinstance(
			    id, attributesetinstance_id, attribute_id, value)
		    VALUES ( _id_attributeinstance ,  _id_temp_asetins ,  _id_color_n, prows.COLOR);

                     

                
                      INSERT INTO stockdiary(
			    id, datenew, reason, location, product, units, price,attributesetinstance_id)
		    VALUES (_id_stock, to_timestamp(prows.fechacompra ,'DD/MM/YYYY'), 1, 0, _id_producto, 1, 
		         cast (coalesce(prows.preciocompra,0) as double precision) ,_id_temp_asetins);


                      IF prows.fechaventa is not null THEN
			      
				_id_stock := _id_stock + 1;

				INSERT INTO stockdiary(
				    id, datenew, reason, location, product,units, price,attributesetinstance_id)
			    VALUES (_id_stock, to_timestamp(prows.fechaventa ,'DD/MM/YYYY'), -1,0, _id_producto,  -1, cast(coalesce(prows.PL,0) as double precision),_id_temp_asetins); 
		   else

			BEGIN 
				 INSERT INTO stockcurrent(
				    location, product,  units,attributesetinstance_id)
				       VALUES ( 0, _id_producto,  1,  _id_temp_asetins);

                       EXCEPTION 


			WHEN unique_violation THEN

                               UPDATE stockcurrent 
                                  SET units = units + 1 
                                WHERE product = CAST(_id_producto AS TEXT) 
                                  AND attributesetinstance_id = CAST(_id_temp_asetins AS TEXT);


			WHEN OTHERS THEN	      

			 RAISE EXCEPTION ' El error fue: %. Producto %. categoria %' ,SQLERRM,prows.descripcion,prows.C;
			
			END ;

			     
                     END IF;
                              
 
    END LOOP;
    


      
	  FOR prows in (select id from "products") LOOP
		 INSERT INTO "products_cat" (product) values  (prows.id);
	  END LOOP;
  
 

	RETURN v_retorno;
	
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION fn_migreta_productos(numeric)
  OWNER TO postgres;
