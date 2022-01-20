-- group fragments of the same streets together (i.e. those split accross junctions)
create or replace function road_groups(geoms geometry[]) returns integer as $$
	declare 
		n int;
	begin
		n := ST_NumGeometries(st_collect(st_clusterwithin(geoms, 0.00001)));
		return n;
	end;
$$ language plpgsql;


-- remove all the extra bits from the street names (e.g. Road, Street, Path, Avenue etc.)
-- so that we are left with just the names of people or other nouns etc
create or replace function remove_fixes(road_name text) returns text as $$
	declare 
		f text;
		cleaned text;
		fixes text[] := array['utca', 'útja', ' út', 'tér', 'tere', 'dűlő', 'körút', 'sor',
					         'sétány', 'magánút', 'parkoló', 'köz', 'lépcső', 'kert', 'rakpart', 'part',
					         'park', 'lakótelep', 'telep', 'liget', 'sugárút',
					         'átjáró', 'híd', 'kerékpárút', 'tanya', 'üdülőpart', 'üdülősor',
					         'felüljáró', 'rakpart', 'aluljáró', 'ösvény', 'udvar',
					         'lejtő', 'pincesor', 'vágány', 'pálya', 'fasor', '-', '.', '"'];
	begin
		cleaned := road_name;
		foreach f in array(fixes) loop
			cleaned := replace(cleaned, f, '');	
		end loop;
		return cleaned;	
	end;
$$ language plpgsql;


do $$
declare


-- count the streets into a new table called 'famous_counts'
-- assumes 'public.planet_osm_line' has been correctly created by osm2pgsql
begin

	drop table if exists roads;
	create table roads as 
	select osm_id, lower(name) as name, st_transform(way, 4326) as geom 
	from public.planet_osm_line where highway is not null and "name" is not null;
	create index road_indx on roads using gist(geom);
	
	drop table if exists roads_grouped_by_name;
	create table roads_grouped_by_name as 
	select a.name, array_agg(geom) as geoms 
	from roads a
	group by a.name;

	drop table if exists roads_grouped_by_name_and_location;
	create table roads_grouped_by_name_and_location as 
	select name, road_groups(geoms)
	from roads_grouped_by_name;
	
	drop table if exists famous_counts;
	create table famous_counts as
	select initcap(c.clean_name) as name, sum(c.road_groups) as n from 
		(select *, remove_fixes(name) as clean_name from roads_grouped_by_name_and_location) c
	where trim(c.clean_name) != ''
	group by c.clean_name
	order by n desc;

	drop table if exists roads_grouped_by_name_and_location;
	drop table if exists roads_grouped_by_name;
	drop table if exists roads;

end
$$;

select * from famous_counts;