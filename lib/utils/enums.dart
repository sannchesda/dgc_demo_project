Map<String, String> transportation = {
  "land": "Land Transportation",
  "sea": "Sea Transportation",
  "normal-air": "Air Courier",
  "express-air": "Express Air",
};

List<Map<String, String>> transportations = [
  {
    "key": "land",
    "value": "Land Transportation",
    "description": "Around 6-8 days",
  },
  {
    "key": "sea",
    "value": "Sea Transportation",
    "description": "Around 10-15 days",
  },
  {
    "key": "normal-air",
    "value": "Air Courier",
    "description": "Around 4-5 days",
  },
  {
    "key": "express-air",
    "value": "Express Air",
    "description": "Around 48 - 72 hours",
  },
];

Map<String, String> orderStatus = {
  "waiting-for-storage": "Waiting for storage",
  "arrived-at-storage": "Arrived at storage",
  "send-storage": "Send to warehouse",
  "arrived-at-warehouse": "Arrived at warehouse",
  "delivered": "Delivered",
  "": "",
};
