namespace :sasami do
  task clean_sotrage: :environment do
    storage_service = ActiveStorage::Blob.service
    if storage_service.name.eql? :local
      FileUtils.rm_rf storage_service.root
      FileUtils.mkdir storage_service.root
    end
  end
end
