# 📱 MoneyMate – Personal Finance App

**MoneyMate** is a cross-platform mobile application built with **Flutter** and powered by **Firebase**. It helps users efficiently and intuitively manage their personal income and expenses, while ensuring data safety and ease of use.

---

## 🎯 Project Scope

### 💰 Transaction Management
- Record income or expense entries with:
  - Amount
  - Date
  - Category (e.g., food, salary, entertainment)
  - Optional notes

### 🗂️ Category Management
- Create, edit, and delete custom income/expense categories.

### 📜 Transaction History
- View past transactions by date or category to keep track of personal finances.

### 📊 Visual Reports
- Display **pie** and **bar** charts to visualize income and spending habits clearly.

### 🔐 User Authentication
- Sign up and log in via:
  - Email/password
  - Phone number with OTP
  - Google account  
- All authentication handled securely using **Firebase Authentication**.

### ☁️ Data Storage
- Store all user data in **Firebase Firestore**, ensuring real-time updates and secure access.

### ⚙️ Account Management
- Edit personal information
- Change password
- Manage wallet types (e.g., cash, bank transfer)

### 🖥️ User Interface (UI)
- Clean, modern design
- Calendar view for transactions
- Dashboard for financial summaries
- Customizable settings screen

---

## 🚧 Future Features (Planned)
- Budget planning
- Payment reminders
- Multi-device data synchronization

---

## 👤 Target Users
- Students, professionals, and homemakers who want better control of their finances
- Users interested in understanding their spending habits and planning budgets
- Tech-savvy individuals who prefer managing finances on their mobile devices

---

## 🛠️ Technologies Used

| Component              | Technology                               |
|------------------------|-------------------------------------------|
| Frontend               | Flutter                                   |
| Backend/Auth           | Firebase Authentication                   |
| Database               | Firebase Firestore                        |
| Charts                 | `fl_chart` or similar charting libraries |
| Google Sign-In         | Firebase Auth + Google Integration        |
| Phone Auth (OTP)       | Firebase Phone Authentication             |

---

## 📸 Demo Screenshots & Videos

Below are some example screenshots showcasing the main features and interfaces of the MoneyMate app.

> **Note:** All screenshots should be placed in the `screenshots/` folder inside the project directory.

---

### 🔐 Authentication
**Login Screen** – Authenticate via MoneyMate account or Google  
![Login](screenshots/login.png)  

**Register – Phone Number Verification**  
![Register Phone 1](screenshots/register-phone1.png)  
![Register Phone 2](screenshots/register-phone2.png)  

**Register – Email Verification**  
![Register Email](screenshots/register-email.png)  

**Final Registration Step**  
![Register Final](screenshots/register-final.png)  

**Forgot Password** – Reset password via email verification code  
![Forgot Password](screenshots/forgot-password.png)  

---

### 🏠 Main Features
**Home Screen** – Overview of balance, monthly income/expenses chart, and quick category list  
![Home](screenshots/home.png)  

**Transaction History** – View transactions by date  
![History By Date](screenshots/history-date.png)  

**History by Category** – View spending within a specific category  
![History By Category](screenshots/history-category.png)  

**Add Expense** – Add and save a new expense  
![Add Expense](screenshots/add-expense.png)  

**Expense Categories** – List of existing expense categories  
![Expense Categories](screenshots/expense-categories.png)  

**Add Expense Category** – Create a new category  
![Add Expense Category](screenshots/add-expense-category.png)  

**Add Income** – Add and save a new income entry  
![Add Income](screenshots/add-income.png)  

**Income Categories** – List of existing income categories  
![Income Categories](screenshots/income-categories.png)  

**Add Income Category** – Create a new income category  
![Add Income Category](screenshots/add-income-category.png)  

---

### 📅 Calendar & Reports
**Calendar** – Monthly view with marked transaction days  
![Calendar 1](screenshots/calendar1.png)  
![Calendar 2](screenshots/calendar2.png)  

**Expense Report** – Column and pie charts with detailed list  
![Expense Report 1](screenshots/report-expense1.png)  
![Expense Report 2](screenshots/report-expense2.png)  

**Income Report** – Column and pie charts with detailed list  
![Income Report 1](screenshots/report-income1.png)  
![Income Report 2](screenshots/report-income2.png)  

---

### ⚙️ Account & Settings
**Account** – View and update user profile  
![Account](screenshots/account.png)  

**Change Password** – Update login password  
![Change Password](screenshots/change-password.png)  

**Drawer Menu** – Access notifications, wallets, settings, and logout  
![Drawer](screenshots/drawer.png)  

**Notifications** – View app activity updates  
![Notifications](screenshots/notifications.png)  

**My Wallet** – Overview of total cash and bank transfers  
![My Wallet](screenshots/wallet.png)  

**Settings** – Language, currency, theme, and data management  
![Settings](screenshots/settings.png)  

---

### 🎥 Demo Video
You can also watch a short demo video of the app:  
[![Watch the video]](https://youtu.be/AHH3pqcdFY4)

---

**Note:** This version focuses on core features. Advanced tools like budgeting and reminders are planned for future releases.
