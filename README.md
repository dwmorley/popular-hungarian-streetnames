### What are the most popular street names in Hungary?

Just for fun. Often you see the same street names in Hungarian towns and villages again and again. Poets, politicians, 
historical figures, but also names of animals, trees etc. I thought it would be interesting to see which occur the most.

I remove all the words relating to street discription (e.g. street, avenue etc.) to leave just the words relating to people or the like.

##### How to get the counts
1) Go to Geofabrik downloads and get the osm.pbf for Hungary
2) Ensure you have a PostGIS enabled Postgres DB (localhost will do)
3) Import the pbf to postgres using osm2pgsql
4) Run the scripts in ```main.sql``` 
5) See the results ```select * from famous_counts```

##### Results (the top 10)

| Name          | Count |            |
|---------------|-------|------------|
| Kossuth Lajos | 1724  | Politician |
| Petőfi Sándor | 1677  | Poet       |
| Ady Endre     | 1499  | Poet       |
| Dózsa György  | 1468  | Soldier    |
| Arany János   | 1272  | Poet       |
| József Attila | 1206  | Poet       |
| Béke          | 1154  | "Peace"    |
| Szabadság     | 1057  | "Freedom"  |
| Petőfi        | 1009  | (? Sándor)   |
