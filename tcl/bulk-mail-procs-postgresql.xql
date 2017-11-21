<?xml version="1.0"?>
<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>
  
  <fullquery name="bulk_mail_base.bulk_mail_base_query">      
    <querytext>
      select site_node__url(site_nodes.node_id)
      from site_nodes
      where site_nodes.object_id = :package_id
    </querytext>
  </fullquery>

</queryset>
