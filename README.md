# GraftGuard – Secure Organ System

**GraftGuard** is an enterprise-grade, secure, web-based organ donation and clinical transplantation management platform. It directly connects organ donors, recipient patients, accredited transplant hospitals, and authorized organ allocation boards through an auditable, transparent digital framework.

---

## 🌟 Key Features

1. **Role-Based Access Control (RBAC)**:
   - **Donor**: Submit pledge, verify medical eligibility, generate official digital donor pledge card.
   - **Recipient / Patient**: Standardized waiting list registry, clinical urgency ranking (Status 1A, 1B, 2, 3), medical document uploads.
   - **Hospital / Medical Team**: Register retrieved organs with Cold Ischemia Time limits, submit emergency organ requests, verify donor/patient documents.
   - **Authorized Organ Allocation Team**: Multi-parametric medical compatibility matching engine (ABO blood matrix, HLA tissue typing, urgency score, waiting tenure, logistics distance). Human-in-the-loop authorization quorum.
   - **Admin**: System health metrics, node supervision, immutable security audit logs with IP tracking.

2. **Organ Viability Tracking**:
   - Live Cold Ischemia countdown timers (Heart 6h, Liver 12h, Kidney 24h).
   - Continuous perfusion temperature monitoring.

3. **7-Stage Organ Transfer Tracking**:
   - `Allocation Approved` → `Hospital Confirmation` → `Organ Preparation` → `Transportation Started` → `In Transit` → `Received by Hospital` → `Transplant Process Confirmation`.

4. **Emergency Escalation Board**:
   - Real-time broadcast alerts for critical organ failure patients requiring urgent board review within 24-48 hours.

---

## 🚀 Pre-Configured Demo Credentials

The database automatically seeds realistic demonstration data on startup:

| Role | Email | Password |
|---|---|---|
| **Admin (System Director)** | `admin@graftguard.org` | `password123` |
| **Hospital (Chief Medical Officer)** | `hospital@graftguard.org` | `password123` |
| **Allocation Team (Board Lead)** | `allocation@graftguard.org` | `password123` |
| **Pledged Organ Donor** | `donor@graftguard.org` | `password123` |
| **Recipient Patient** | `patient@graftguard.org` | `password123` |

*(Tip: On the Login page, click the role tabs and press **"Auto Fill"** to instantly test each role!)*

---

## 🛠️ Technology Stack

- **Frontend**: React.js, Vite, Tailwind CSS, Lucide Icons, Axios, React Router v6.
- **Backend**: Node.js, Express.js.
- **Database**: MongoDB, Mongoose ODM.
- **Security**: JWT Authentication, bcryptjs password hashing, Multer secure file handling, immutable audit logs.

---

## 💻 How to Run the Project

### Option 1: One-Click Quick Launch (Windows)
Double-click `run-all.bat` in the project root directory. It will start both the backend API and the frontend client in separate windows!

### Option 2: Manual Terminal Execution

#### 1. Start MongoDB
Ensure MongoDB is running on your machine:
```bash
net start MongoDB
```

#### 2. Start the Backend API Server
Open a terminal in the `backend` folder:
```bash
cd backend
npm start
```
*Backend runs on: `http://localhost:5000`*

#### 3. Start the Frontend Client
Open another terminal in the `frontend` folder:
```bash
cd frontend
npm run dev
```
*Frontend runs on: `http://localhost:5173`*

---

## 📂 Project Architecture

```
Mini project/
├── backend/
│   ├── config/          # MongoDB connection & memory fallback
│   ├── controllers/     # Auth, Donors, Recipients, Organs, Matching, Allocations, Transfers, Emergencies
│   ├── middleware/      # JWT Protect, Role Authorization, Multer Upload, Audit Logger
│   ├── models/          # 11 Mongoose Schemas (User, Donor, Recipient, Organ, Hospital, etc.)
│   ├── routes/          # RESTful API route endpoints
│   ├── services/        # Matching algorithm engine & Database seeder
│   ├── uploads/         # Uploaded patient test reports and clinical docs
│   ├── .env             # Environment variables
│   └── server.js        # Main Express server entry point
├── frontend/
│   ├── src/
│   │   ├── components/  # Navbar, Sidebar, Footer, StatCard, Stepper, ViabilityTimer, DonorCard
│   │   ├── context/     # AuthContext (JWT, session, role routes)
│   │   ├── pages/       # Home, Dashboards (all 5 roles), Inventory, Matching, Emergency, Transfers
│   │   ├── services/    # Axios API client functions
│   │   ├── App.jsx      # React router routing and role guards
│   │   └── main.jsx     # Vite React mount
│   ├── package.json
│   └── vite.config.js
├── run-all.bat          # 1-click launcher for frontend + backend
├── run-backend.bat      # 1-click backend launcher
└── run-frontend.bat     # 1-click frontend launcher
```

