<?xml version="1.0"?>
<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="bulk_mail::url_not_cached.select_bulk_mail_url">      
    <querytext>
      select site_node.url(site_nodes.node_id)
      from site_nodes
      where site_nodes.object_id = :package_id
    </querytext>
  </fullquery>

</queryset>
