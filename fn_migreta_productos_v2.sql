-- Function: fn_migreta_productos_new()

-- DROP FUNCTION fn_migreta_productos_new();

CREATE OR REPLACE FUNCTION fn_migreta_productos_new()
  RETURNS numeric AS
$BODY$

 DECLARE
	v_retorno			numeric; 
        _id_categoria    		numeric;
        _id_attributeset 		numeric;
        _id_talle 	 		numeric;
        _id_color       		numeric;
        _id_attributeuse 		numeric;
        _id_attributevalue       	numeric;
        _id_producto                    numeric;
        _id_attributeinstance		numeric;
        _id_attributesetinstance        numeric;
        _id_stockdiary			numeric;
        _id_stockcurrent  		numeric;
         v_cant_novendido		numeric;
         lista			        record; -- categorias
 
 BEGIN
    
 FOR lista in ( select    "codcombi"  as codcombi,"C" as C,"DESCRIPCION" as DESCRIPCION,
                            "º" AS   preciocompra, "PL"  AS PL ,
                             '<html>' || "DESCRIPCION" || ' - ' || upper(trim("TALLE")) ||  ', ' || upper(trim("COLOR"))   AS display,  
                             "PROV"  as PROV,1  as cantidad,"VENDIDO/NO VENDIDO" as fechaventa , "FECHA COMPRA" as fechacompra,
                             UPPER(TRIM("TALLE")) as TALLE
                             ,UPPER(TRIM("COLOR"))as COLOR  
                             ,rtrim("C")  as categorias,
                            rtrim("PROV")  as proveedor   FROM "LISTAS")  LOOP
                            
                            
        SELECT count(*)  into _id_categoria
                         FROM categories 
                        WHERE  name = lista.proveedor ;

	 if   _id_categoria = 0 then
			    
		  _id_categoria := (SELECT coalesce ( max(cast (id as numeric) ), '0')  + 1  	   
		                      FROM categories );

		  INSERT INTO categories(
			      id,name  )
			  VALUES (_id_categoria, lista.proveedor );

	         
	 else

		 _id_categoria := ( SELECT cast(id  as numeric)  
                    FROM categories 
	           WHERE  name = lista.proveedor );
    
	 end if;


          _id_attributeset :=(  SELECT count(*)  
                                FROM attributeset 
                                WHERE  name = 'Atributos de ' || lista.categorias) ;


          if   _id_attributeset = 0 then
			    
		 _id_attributeset:= (  SELECT coalesce(max(cast (id as numeric) ),0)  + 1  
				    FROM attributeset );

                    INSERT INTO attributeset( id, name)
		         VALUES ( _id_attributeset , 'Atributos de ' || lista.categorias  );	
         
	 else

		_id_attributeset := (SELECT cast(id as numeric)
				      FROM  attributeset 
				     WHERE  name = 'Atributos de ' || lista.categorias  );

         end if;

    
                        
       --fin  conjuntos de atributos
       
       --3) conjuntos de atributos talle

       _id_talle := (SELECT count(*) 
                             FROM attribute 
                            WHERE  name =  'Talle de ' ||  lista.categorias )  ;

        if  _id_talle = 0 then
			    
		      _id_talle := (SELECT coalesce (max(cast(id as numeric)),0)  + 1 
				    FROM attribute );

                      INSERT INTO attribute(id, name)
			VALUES (_id_talle  , 'Talle de ' ||   lista.categorias );  
                  

                    _id_attributeuse := (SELECT count (*)
                             FROM attributeuse
                            WHERE  cast( attributeset_id as numeric) =  _id_attributeset  
                              AND   cast(attribute_id as numeric)    =  _id_talle )  ;


                    IF _id_attributeuse = 0 then 
                    
                      _id_attributeuse  := (SELECT coalesce(MAX(cast(ID as numeric)),0) + 1
                             FROM attributeuse)  ;


			    INSERT INTO attributeuse(
			       id, attributeset_id, attribute_id )
				  VALUES (  _id_attributeuse  ,  _id_attributeset , _id_talle);
                    
                     END IF;
                     
       
	 else

		_id_talle   := (SELECT cast(id as numeric)
				    FROM  attribute 
				   WHERE  name =  'Talle de ' ||   lista.categorias );
        
	 end if;
                     
   
       --fin conjuntos de atributos

         --4) conjuntos de atributos color

       _id_color := (SELECT count(*) 
                             FROM attribute 
                            WHERE  name =  'Color de ' ||  lista.categorias )  ;

        if  _id_color = 0 then
			    
		      _id_color := (SELECT coalesce(max(cast(id as numeric)),0)  + 1 
				    FROM attribute );

                 
                      INSERT INTO attribute(id, name)
			VALUES (_id_color , 'Color de ' ||   lista.categorias );

	      

                    _id_attributeuse := (SELECT count(*) 
                             FROM attributeuse
                            WHERE   cast(attributeset_id as numeric)=  _id_attributeset 
                              AND   cast(attribute_id as numeric)   =  _id_color )  ;


                    IF _id_attributeuse = 0 then 
                    
                      _id_attributeuse  := (SELECT coalesce(MAX(cast(ID as numeric)),0) + 1
                             FROM attributeuse)  ;


			    INSERT INTO attributeuse(
			       id, attributeset_id, attribute_id )
				  VALUES (  _id_attributeuse  ,  _id_attributeset , _id_color);
                    
                     END IF;


	 else

		_id_color   := (SELECT cast(id as numeric)
				    FROM  attribute 
				   WHERE  name =  'Color de ' ||   lista.categorias );

        
	 end if;
                        
       --fin conjuntos de atributos

          _id_attributevalue := (Select count(*) 
                                  from attributevalue 
                                 where cast(attribute_id as numeric) = _id_talle 
                                   and value = lista.TALLE);

          if _id_attributevalue = 0 then 

		 _id_attributevalue := (select coalesce(max(cast(id as numeric)),0) + 1 
		                          from attributevalue);
		  
	 
		 INSERT INTO attributevalue(
					    id, attribute_id, value)
				    VALUES (_id_attributevalue, _id_talle, lista.TALLE);

         end if;
         


          _id_attributevalue := (Select count(*) 
                                  from attributevalue 
                                 where cast(attribute_id as numeric) = _id_color
                                   and value = lista.COLOR);

          if _id_attributevalue = 0 then 

		 _id_attributevalue := (select coalesce(max(cast(id as numeric)),0) + 1 
		                          from attributevalue);
		  
	 
		 INSERT INTO attributevalue(
					    id, attribute_id, value)
				    VALUES (_id_attributevalue, _id_color, lista.COLOR);

         end if;
 
     

       

      _id_producto :=  (select count(*) from products where code = lista.codcombi);

     if _id_producto = 0 then 

     _id_producto  := (select coalesce(max(cast(id as numeric)),0) + 1 from products );
          
      
                       INSERT INTO products(
				id, reference, code,   name, pricebuy, pricesell, category, 
				taxcat, attributeset_id,  iscom, 
				isscale, iskitchen, printkb, sendstatus, isservice, display )
			    VALUES (_id_producto, coalesce( lista.codcombi,' '), coalesce(lista.codcombi,' '), lista.descripcion || ', ' || trim(coalesce(lista.TALLE,'') || ', ' || coalesce(lista.COLOR,'')) , 
                                 coalesce(cast(lista.preciocompra as numeric),0),coalesce(cast(lista.PL as numeric),0),_id_categoria, '000', 
				_id_attributeset ,  FALSE, FALSE, 
			    FALSE, FALSE, FALSE, FALSE,lista.display  );

      else

      _id_producto := (select cast(id as numeric) 
                        from products 
                       where code = lista.codcombi );

     end if;

     

         IF   lista.fechaventa IS  NULL THEN 
		v_cant_novendido := 1;
         END IF;


         _id_attributesetinstance := (select count(*) 
                                        from attributesetinstance 
                                       where cast(attributeset_id as numeric) = _id_attributeset
                                         and description = lista.TALLE || ', ' || lista.COLOR );

          if _id_attributesetinstance = 0 then 

          _id_attributesetinstance := (select coalesce(max(cast(id as numeric)),0) + 1 from attributesetinstance);
               
                       INSERT INTO attributesetinstance(id, attributeset_id, description)
			    VALUES (_id_attributesetinstance,_id_attributeset, lista.TALLE || ', ' || lista.COLOR);

          else

          _id_attributesetinstance := (select cast(id as numeric) 
                                         from attributesetinstance 
                                        where cast(attributeset_id as numeric)= _id_attributeset
                                          and description = lista.TALLE || ', ' || lista.COLOR);

          end if;

 

          _id_attributeinstance := (select cast (id as numeric) from attributeinstance 
                                             where cast(attributesetinstance_id as numeric) = _id_attributesetinstance
                                               and cast(attribute_id as numeric) = _id_talle);


           if _id_attributeinstance = 0  then 
           
            _id_attributeinstance  := (select coalesce(max(cast(id as numeric)),0) + 1  
                                         from attributeinstance );

                 INSERT INTO attributeinstance(
			    id, attributesetinstance_id, attribute_id, value)
		    VALUES ( _id_attributeinstance ,  _id_attributesetinstance ,_id_talle , lista.TALLE);

           end if;
           
	 

          _id_attributeinstance := (select cast(id as numeric)    from attributeinstance 
                                             where cast(attributesetinstance_id as numeric)= _id_attributesetinstance
                                               and cast(attribute_id as numeric) = _id_color);


           if _id_attributeinstance = 0  then 
           
           _id_attributeinstance  := (select coalesce(max(cast(id as numeric)),0) + 1  
                                        from attributeinstance );

                 INSERT INTO attributeinstance(
			    id, attributesetinstance_id, attribute_id, value)
		    VALUES ( _id_attributeinstance ,  _id_attributesetinstance ,_id_color , lista.COLOR);

           end if;

 


               _id_stockdiary := (SELECT count(*)  
                                    FROM stockdiary   
                                   WHERE    datenew  =  to_timestamp(lista.fechacompra ,'DD/MM/YYYY')
                                     AND     reason  =  1
                                     AND   cast(location as numeric)  =  0 
                                     AND    cast(product as numeric)  =  _id_producto
                                     AND      units  =  1
                                     AND      price  =   cast (coalesce(lista.preciocompra,0) as double precision)
                                     AND    cast(attributesetinstance_id as numeric) = _id_attributesetinstance
                                     );  


		    if   _id_stockdiary = 0 then 
		    
		      _id_stockdiary := (select coalesce(max(cast(id as numeric)),0) + 1 
		                           from stockdiary);

			   INSERT INTO stockdiary(id, datenew, reason, location, product, units, price,attributesetinstance_id)
				    VALUES (_id_stockdiary , to_timestamp(lista.fechacompra ,'DD/MM/YYYY'), 1, 0, _id_producto, 1, 
					 cast (coalesce(lista.preciocompra,0) as double precision) ,_id_attributesetinstance);
		    end if;

   
               
 

         IF lista.fechaventa is not null THEN



                _id_stockdiary := (SELECT count(*)  
                                    FROM stockdiary   
                                   WHERE    datenew  =  to_timestamp(lista.fechaventa ,'DD/MM/YYYY')
                                     AND     reason  =  -1
                                     AND   cast(location as numeric) =  0 
                                     AND   cast( product as numeric) =  _id_producto
                                     AND      units  =  1
                                     AND      price  =   cast (coalesce(lista.PL,0) as double precision)
                                     AND   cast( attributesetinstance_id as numeric) = _id_attributesetinstance
                                     );  

                   if _id_stockdiary = 0 then

			       _id_stockdiary := (select coalesce(max(cast(id as numeric)),0) + 1 
			                            from stockdiary 
			                           where (id ~ '^[0-9]+$') = 't' );



				INSERT INTO stockdiary(
				    id, datenew, reason, location, product,units, price,attributesetinstance_id)
			    VALUES (_id_stockdiary , to_timestamp(lista.fechaventa ,'DD/MM/YYYY'), -1,0, _id_producto,  
                         -1, cast(coalesce(lista.PL,0) as double precision),_id_attributesetinstance); 


			end if;

		   else
 
		      _id_stockcurrent := (SELECT  count(*)  
				     FROM  stockcurrent   
				    WHERE   cast( location as numeric) = 0 			
				      AND  cast( product as numeric) = _id_producto
				      AND   units  = 1
				      AND  cast( attributesetinstance_id  as numeric)= _id_attributesetinstance
				     );  

		      if _id_stockcurrent = 0 then
			   
			        INSERT INTO stockcurrent(
				    location, product,  units,attributesetinstance_id)
				       VALUES ( 0, _id_producto,  1,  _id_attributesetinstance);

		      end if;
                    
			      
                    END IF;



end loop;


	
delete from products_cat;
      
	  FOR lista in (select id from "products") LOOP
		 INSERT INTO "products_cat" (product) values  (lista.id);
	  END LOOP;
  
 

	RETURN v_retorno;
	
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION fn_migreta_productos_new()
  OWNER TO postgres;
