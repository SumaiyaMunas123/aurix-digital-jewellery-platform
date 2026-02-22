import React, { useState } from "react";
import "./OrdersDashboard.css";

const tabs = ["All Orders", "Pending", "Processing", "Shipped", "Delivered", "Cancelled"];

const orders = [
  { id: "ORD-8492", customer: "Amara Silva", email: "amara@email.com", initials: "AS", jeweler: "Golden Aura Jewelry", item: "Diamond Ring 2ct", amount: 4800.00, date: "Oct 14, 2023", status: "Processing" },
  { id: "ORD-8491", customer: "Ravi Perera", email: "ravi@email.com", initials: "RP", jeweler: "Diamond District Co.", item: "Gold Cuban Link", amount: 1200.00, date: "Oct 13, 2023", status: "Delivered" },
  { id: "ORD-8490", customer: "Nisha Fernando", email: "nisha@email.com", initials: "NF", jeweler: "Legacy Jewels", item: "Pearl Drop Earrings", amount: 850.00, date: "Oct 13, 2023", status: "Shipped" },
  { id: "ORD-8489", customer: "Kiran Jayasena", email: "kiran@email.com", initials: "KJ", jeweler: "Orchid Gem House", item: "Emerald Band Platinum", amount: 1800.00, date: "Oct 12, 2023", status: "Pending" },
  { id: "ORD-8488", customer: "Dulani Wickrama", email: "dulani@email.com", initials: "DW", jeweler: "Sunrise Jewels", item: "Sapphire Tennis Bracelet", amount: 3200.00, date: "Oct 12, 2023", status: "Processing" },
  { id: "ORD-8487", customer: "Tharidu Saman", email: "tharidu@email.com", initials: "TS", jeweler: "Crystal Ridge", item: "Rose Gold Bangle Set", amount: 620.00, date: "Oct 11, 2023", status: "Cancelled" },
  { id: "ORD-8486", customer: "Mala Gunawardena", email: "mala@email.com", initials: "MG", jeweler: "Golden Aura Jewelry", item: "White Gold Necklace", amount: 2100.00, date: "Oct 10, 2023", status: "Delivered" },
  { id: "ORD-8485", customer: "Shan Bandara", email: "shan@email.com", initials: "SB", jeweler: "Diamond District Co.", item: "Diamond Stud Set", amount: 1650.00, date: "Oct 10, 2023", status: "Pending" },
];

const statusClassMap = {
  Pending:    "os-pill os-pending",
  Processing: "os-pill os-processing",
  Shipped:    "os-pill os-shipped",
  Delivered:  "os-pill os-delivered",
  Cancelled:  "os-pill os-cancelled",
};

return ()=>{

};

export default OrdersDashboard;
