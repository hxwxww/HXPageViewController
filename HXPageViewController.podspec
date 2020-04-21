Pod::Spec.new do |s|

  s.name            = 'HXPageViewController'
  s.version         = '0.0.2'
  s.summary         = 'A pageViewController which manage childViewController appearance transition'

  s.homepage        = 'https://github.com/hxwxww/HXPageViewController'
  s.license         = 'MIT'

  s.author          = { 'hxwxww' => 'hxwxww@163.com' }
  s.platform        = :ios, '9.0'
  s.swift_version   = '5.0'

  s.source          = { :git => 'https://github.com/hxwxww/HXPageViewController.git', :tag => s.version }

  s.source_files    = 'HXPageViewController/HXPageViewController/HXPageViewController/*.swift'

  s.frameworks      = 'Foundation', 'UIKit'

end
