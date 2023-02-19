with valid_customer_addresses as (select 
    ca.customer_id,
    ca.address_id,
    ca.customer_city,
    ca.customer_state,
    uc.geo_location
from 
    vk_data.customers.customer_address as ca inner join
    vk_data.resources.us_cities as uc
on 
    lower(ca.customer_city) = lower(uc.city_name) and 
    lower(ca.customer_state) = lower(uc.state_abbr)),
    
supplier_addresses as (select 
    si.supplier_id,
    si.supplier_name,
    si.supplier_city,
    si.supplier_state,
    uc.geo_location
from 
    vk_data.suppliers.supplier_info as si inner join
    vk_data.resources.us_cities as uc
on 
    lower(si.supplier_city) = lower(uc.city_name) and 
    lower(si.supplier_state) = lower(uc.state_abbr)),
    
all_customer_supplier_distances as (select 
	ca.customer_id,
    sa.supplier_id,
    sa.supplier_name,
    st_distance(ca.geo_location,sa.geo_location)/1000  as cust_suppl_dist
from valid_customer_addresses  as ca cross join 
    supplier_addresses as sa),

min_customer_supplier_distances as (select
	customer_id,
    min(cust_suppl_dist) as min_dist
from all_customer_supplier_distances
group by customer_id),

cust_suppl_shipping_details as (select 
	ad.customer_id,
    ad.supplier_id,
    ad.supplier_name,
    md.min_dist	as shipping_dist
from min_customer_supplier_distances as md inner join 
	 all_customer_supplier_distances as ad
on md.customer_id = ad.customer_id and
	md.min_dist = ad.cust_suppl_dist)

select 
	c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    d.supplier_id,
    d.supplier_name,
    d.shipping_dist as shipping_dist_in_kms
from cust_suppl_shipping_details as d inner join 
	 vk_data.customers.customer_data as c
on d.customer_id = c.customer_id
order by c.last_name, c.first_name
