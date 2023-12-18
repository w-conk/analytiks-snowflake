{% macro limit_data_in_dev(column_name,num_days=3) %}
where {{ column_name }} >= dateadd('day',-{{ num_days }}, (SELECT MAX({{ column_name }}) FROM final))
{% endmacro %}