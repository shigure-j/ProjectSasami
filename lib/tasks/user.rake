namespace :sasami do
  task local_init: [:environment, 'db:reset', 'db:migrate', 'db:seed'] do
    storage_service = ActiveStorage::Blob.service
    if storage_service.name.eql? :local
      FileUtils.rm_rf storage_service.root
      FileUtils.mkdir storage_service.root
    end
  end

  task init: [:local_init, 'yarn:install', 'assets:clobber', 'assets:precompile'] do
  end
end
