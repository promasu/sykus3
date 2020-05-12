module Sykus

  # Global Redis connection instance.
  REDIS = Redis.new({
    driver: :hiredis,
    path: '/run/redis/redis-server.sock',
    db: (APP_ENV == :test) ? 2 : 1,
  })

end

