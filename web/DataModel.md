# User Model

id: string
service_credenitals: ServiceCredential[]
song_shares: SongShare[]

# Service Credential

user_id: string
service: string
service_user_id: string
access_token: string
refresh_token: string
token_expiry: datetime

# Bounce

id: string
url: string
shared_at: datetime
artist: string
title: string
album: string
artwork_url: string

# Bounce Listen

id: string
bounce_id: string
listened_at: datetime
user_id: string
device_type: string

# Activity Log

id: string
user_id: string
activity_type: string
activity_data: json
created_at: datetime
