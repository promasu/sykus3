root = File.absolute_path(File.dirname(__FILE__))

file_cache_path = root
data_bag_path File.absolute_path(root + '/../data_bag') 
cookbook_path [ root, root + '/packages' ]

