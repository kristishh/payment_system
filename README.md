# Prerequisites and Package Versions
* Ruby 3.4.7
* Rails 8.1
* React 19.2
* React-Redux 9.2
* React-Bootstrap 2.10
* TailwindCSS 4.1

# Application setup
### Ruby on Rails API
```console
cd server_side
bundle install
rails credentials:edit
rails db:create
rails db:migrate
rails users:create_users
```
### React App
```console
cd client-side
npm install
```

# Running the Application

### Start Ruby on Rails API
```console
cd server_side
cd server
rails s
```

### Start React App
```console
cd client-side
npm run dev
```

__The application is now fully running. Navigate to http://localhost:3001 to view the app.__

##### *Don't forget to use users from seeds.

# Create transactions using endpoint

1. Set up authorization header (should be a merchant token).
2. Create a post request to */transactions*
3.  Put body request
   
         Example:
      
           
              {
                "transaction": {
                    "type": "authorize",
                    "amount": 25,
                    "customer_email": "john_doe@example.com",
                    "customer_phone": "555-123-4567",
                    "status": "approved"
                    // "reference_transaction_id": ""
                }
             }
   

