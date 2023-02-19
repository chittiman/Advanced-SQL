select 
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
    lower(ca.customer_state) = lower(uc.state_abbr)
