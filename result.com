<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Jamia-Al-Hind</title>
  <link rel="icon" href="https://i.postimg.cc/qqsPbG9V/jamia-al-hind-01.png" sizes="48x48" type="image/png">
  <style>
    /* CSS Styles */
    body {
      font-family: Arial, sans-serif;
      margin: 20px;
      background-color: #f7f7f7;
    }
    h1 {
      text-align: center;
      color: #333;
    }
    .form-container {
      display: flex;
      flex-direction: column;
      max-width: 400px;
      margin: auto;
      gap: 10px;
      margin-bottom: 30px;
    }
    input, button {
      padding: 10px;
      font-size: 16px;
    }
    button {
      background-color: #4CAF50;
      color: white;
      border: none;
      cursor: pointer;
    }
    button:hover {
      background-color: #45a049;
    }
    #results {
      text-align: center;
    }
    #studentNameHeader {
      font-size: 24px;
      font-weight: bold;
      color: #4CAF50;
      margin-bottom: 10px;
    }
    table {
      width: 100%;
      max-width: 600px;
      margin: auto;
      border-collapse: collapse;
    }
    th, td {
      padding: 12px;
      border: 1px solid #ddd;
      text-align: center;
    }
    thead {
      background-color: #4CAF50;
      color: white;
    }
    .low-mark {
      color: red;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <h1>Student Result Lookup</h1>
  <!-- Form to search for a student by registration number -->
  <div class="form-container">
    <input type="text" id="regNumber" placeholder="Enter Registration Number" required>
    <button onclick="lookupResult()">Search</button>
  </div>

  <!-- Section to display the result -->
  <div id="results">
    <div id="studentNameHeader" style="display:none;"></div>
    <table id="studentTable" style="display:none;">
      <thead>
        <tr>
          <th>Subject</th>
          <th>Mark</th>
          <th>CE Mark</th>
        </tr>
      </thead>
      <tbody id="resultBody">
      </tbody>
    </table>
    <p id="notFound" style="color:red; display:none;">Student not found. Please check the registration number.</p>
  </div>

  <script>
    const students = [
  { regNumber: "M1B1", name: "ABDUL MALIK", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [17,14], ceMarks: [ 10,8,9,9,10,8,9,9,10,8] },
  { regNumber: "M1B2", name: "ABDULLA RABEE K", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,9,9,10,10,6,9,10,10,7] },
  { regNumber: "M1B3", name: "ABDULLAH AL SABITH CT", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [8,9,7,9,10,7,8,8,8,5] },
  { regNumber: "M1B4", name: "ANSAR VM", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,7,10,10,10,9,8,10,8] },
  { regNumber: "M1B5", name: "ASWEEL UL JAFFER", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [9,7,5,7,4,6,6,7,7,4] },
  { regNumber: "M1B6", name: "FAHEEM ABDULLH", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,7,9,10,6,7,8,10,5] },
  { regNumber: "M1B7", name: "FARDEEN FATHAH", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [] },
  { regNumber: "M1B8", name: "JAZEEM SHAN PV", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,8,9,8,10,9,9,9,6] },
  { regNumber: "M1B9", name: "MOHAMMED FAZIL KT", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,9,8,9,10,7,9,10,10,5] },
  { regNumber: "M1B10", name: "MOHAMMED HATHIM", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,8,8,10,6,8,10,10,4] },
  { regNumber: "M1B11", name: "MOHAMMED HUMRAS EBRAHIM CS", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,9,8,9,6,6,7,8,9,6] },
  { regNumber: "M1B12", name: "MOHAMMED MUNEEB KV", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,7,9,10,8,8,9,10,4] },
  { regNumber: "M1B13", name: "MOHAMMED RAIHAN", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [8,7,7,9,5,8,9,8,8,4] },
  { regNumber: "M1B14", name: "MUHAMMED AL FAJR", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [8,7,5,6,4,6,5,7,8,6] },
  { regNumber: "M1B15", name: "MUHAMMED ASLAM", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,9,9,10,10,9,9,9,7] },
  { regNumber: "M1B16", name: "MUHAMMED AFNAN TM", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [9,6,8,10,10,10,9,9,9,5] },
  { regNumber: "M1B17", name: "MUHAMMED BILAL MS", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [7,7,4,6,6,7,7,8,10,5] },
  { regNumber: "M1B18", name: "MUHAMMED FALAH M", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,9,9,10,10,10,10,10,8,7] },
  { regNumber: "M1B19", name: "MUHAMMED HANAN CA", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [39,38,37,40,40,,,40,40,39], ceMarks: [10,9,9,10,10,8,10,10,10,9] },
 
  { regNumber: "M1B20", name: "MUHAMMED KV", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,8,10,10,6,10,9,10,7] },
  { regNumber: "M1B21", name: "MUHAMMED P", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,8,9,10,10,9,10,10,9] },
  { regNumber: "M1B22", name: "MUHAMMED RISHAN K", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [7,5,7,7,10,5,8,7,8,4] },
  { regNumber: "M1B23", name: "MUHAMMED SAHAL KP", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,6,9,8,4,8,8,7,10,6] },
  { regNumber: "M1B24", name: "MUHAMMED SWALIH CM", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,6,7,9,10,8,9,8,9,7] },
  { regNumber: "M1B25", name: "MUNEEB BIN MUSTHAFA VK", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [9,7,5,9,7,8,7,7,9,4] },
  { regNumber: "M1B26", name: "SADHRUDEEN M", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [8,6,4,6,5,5,6,8,8,7] },
  { regNumber: "M1B27", name: "SAFWAN C", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,9,8,10,10,9,10,10,10,9] },
  { regNumber: "M1B28", name: "SHADIL NM", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [8,8,8,10,4,9,9,9,10,6] },
  { regNumber: "M1B29", name: "SHAHAN SIDEEQUE PK", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [8,8,6,7,6,10,7,8,8,5] },
  { regNumber: "M1B30", name: "SHAHID BILAL MN", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,8,7,10,5,6,10,10,10,9] },
  { regNumber: "M1B31", name: "UKKASHA PH", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,9,8,10,8,8,9,9,10,6] },
  { regNumber: "M1B32", name: "WAJEEH P", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,9,9,10,10,10,10,10,9,7] },
  { regNumber: "M1B33", name: "ZAINUL ABID K", subjects: ["Hifz", "Thafseer", "Manhaju salaf", "Nahwu", "Sarf", "Thahbeer", "Kirath", "Durusulluga", "Urdu", "English"], marks: [], ceMarks: [10,7,8,8,8,8,8,8,10,8] },
];

    function lookupResult() {
      const regNumber = document.getElementById("regNumber").value.trim();
      const student = students.find(s => s.regNumber === regNumber);

      if (student) {
        document.getElementById("studentNameHeader").textContent = student.name;
        document.getElementById("studentNameHeader").style.display = "block";

        const resultBody = document.getElementById("resultBody");
        resultBody.innerHTML = "";

        student.subjects.forEach((subject, index) => {
          const row = document.createElement("tr");

          const subjectCell = document.createElement("td");
          subjectCell.textContent = subject;
          row.appendChild(subjectCell);

          const markCell = document.createElement("td");
          const mark = student.marks[index];
          if (mark < 16) {
            markCell.textContent = `${mark} `;
            markCell.classList.add("low-mark");
          } else {
            markCell.textContent = mark;
          }
          row.appendChild(markCell);

          const ceMarkCell = document.createElement("td");
          ceMarkCell.textContent = student.ceMarks[index] || 0;
          row.appendChild(ceMarkCell);

          resultBody.appendChild(row);
        });

        document.getElementById("studentTable").style.display = "table";
        document.getElementById("notFound").style.display = "none";
      } else {
        document.getElementById("studentTable").style.display = "none";
        document.getElementById("studentNameHeader").style.display = "none";
        document.getElementById("notFound").style.display = "block";
      }
    }
  </script>
<button class="print-btn" onclick="window.print();">Print Table</button>
</body>
</html>
