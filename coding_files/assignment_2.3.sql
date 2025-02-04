-- create schema
create schema bi_trigger;

-- create product_current table
create table bi_trigger.product_current (
    product_durable_sk serial primary key,
    product_name varchar(100),
    product_category varchar(50),
    last_update date default current_date
);

-- create product_history table
create table bi_trigger.product_history (
    product_sk serial primary key,
    product_durable_sk integer,
    effective_date date,
    ineffective_date date,
    current_indicator boolean,
    product_name varchar(100),
    product_category varchar(50)
);

-- create fact_sale table
create table bi_trigger.fact_sale (
    product_sk integer,
    product_durable_sk integer,
    date_sk integer,
    sales_quantity integer,
    unit_price decimal(10,3),
    constraint primary_key_fact primary key (product_sk, product_durable_sk, date_sk),
    constraint product_sk_fk foreign key (product_sk) references bi_trigger.product_history(product_sk),
    constraint product_durable_sk_fk foreign key (product_durable_sk) references bi_trigger.product_current(product_durable_sk)
);

-- insert into product_current
insert into bi_trigger.product_current (product_durable_sk, product_name, product_category, last_update) values
(1, 'Laptop X1 Pro', 'Electronics', '2023-11-09'),
(2, 'Smartphone Z2', 'Mobile Devices', '2023-10-10');

-- insert into product_history
insert into bi_trigger.product_history (product_sk ,product_durable_sk, effective_date, ineffective_date, current_indicator, product_name, product_category) values
(default, 1, '2023-02-01', '2023-10-09', false, 'Laptop X1', 'Electronics'),
(default, 2, '2023-10-10', '9999-10-10', true, 'Smartphone Z2', 'Mobile Devices'),
(default, 1, '2023-11-09', '9999-11-09', true, 'Laptop X1 Pro', 'Electronics');

-- insert into fact_sale
insert into bi_trigger.fact_sale (product_sk, product_durable_sk, date_sk, sales_quantity, unit_price) values
(1, 1, 20230202, 10, 349),
(2, 2, 20231018, 5, 20),
(3, 1, 20230915, 15, 503);

-- create trigger function
create or replace function log_product_changes()
returns trigger
language plpgsql
as
$$
begin
    if new.product_name <> old.product_name then
        -- update ineffective date and current indicator on current record
        update bi_trigger.product_history
        set ineffective_date = current_date,
            current_indicator = false
        where product_durable_sk = old.product_durable_sk
        and current_indicator = true;
        
        -- insert new record
        insert into bi_trigger.product_history(
            product_sk, product_durable_sk,
            effective_date, ineffective_date,
            current_indicator, product_name, product_category)
        values(
            default, old.product_durable_sk,
            current_date, '9999-12-31',
            true, new.product_name, old.product_category
        );
    end if;
return new;
end;
$$;

-- create the trigger
create trigger product_name_changes
before update on bi_trigger.product_current
for each row
execute procedure log_product_changes();

-- update product name
update bi_trigger.product_current
set product_name = 'Laptop X1 Pro Business',
    last_update = default
where product_durable_sk = 1;