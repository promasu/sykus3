root = File.absolute_path(File.dirname(__FILE__))

file_cache_path = root
data_bag_path File.join(root, 'data_bag') 
cookbook_path [ File.join(root, 'common'), File.join(root, 'sykussrv') ]

