= Evaluation

We plan to evaluate the application by the following 4 objectives:
- *Data Accuracy*
- *Data Consistency*
- *Performance*

== Data Accuracy:

Ensure the correctness of data operations including adding, deleting, modifying, and querying.

=== Insert a new record and verify successful insertion

```java
@Test
void addNewPerson() throws Exception {
  mockMvc.perform(post("/api/scholar/add")
    .param("name", "Chentian Wu")
    .param("major", "Math")
    .param("hindex", "1")
    .param("location", "University of Wisconsin-Madison"))
    .andExpect(status().isOk())
    .andExpect(content().string("Person added successfully"));
  verify(peopleService).addNewPerson("Chentian Wu", "Math", 1, "University of Wisconsin-Madison");
}
```

=== Read an existing record and verify data correctness
```java
@Test
void getPersonProfile() throws Exception {
  Long personId = 185026L;
  Map<String, Object> profile = new HashMap<>();
  profile.put("name", "Chia Y. Cho");
  profile.put("major", "computerscience");
  profile.put("hindex", 20);
  when(peopleService.getPersonProfile(personId)).thenReturn(profile);
  mockMvc.perform(get("/api/scholar/{personId}/profile", personId))
  .andExpect(status().isOk())
  .andExpect(jsonPath("$.name").value("Chia Y. Cho"))
  .andExpect(jsonPath("$.major").value("computerscience"))
  .andExpect(jsonPath("$.hindex").value(20));
  verify(peopleService).getPersonProfile(personId);
}
```

=== Update a record and verify changes are saved

```java
@Test
void updatePublicationAndVerifyChanges() throws Exception {
  Long pubId = 1L;
  Publication existingPublication = new Publication();
  existingPublication.setPubid(pubId);
  existingPublication.setDoi("10.1000/original");
  Publication updatedPublication = new Publication();
  updatedPublication.setPubid(pubId);
  updatedPublication.setDoi("10.1000/updated");
  when(publicationsService.findById(pubId)).thenReturn(existingPublication);
  when(publicationsService.save(any(Publication.class))).thenReturn(updatedPublication);
  mockMvc.perform(put("/api/pub/{id}", pubId)
    .contentType(MediaType.APPLICATION_JSON)
    .content("{\"doi\":\"10.1000/updated\"}"))
    .andExpect(status().isOk())
    .andExpect(jsonPath("$.doi").value("10.1000/updated"));
  verify(publicationsService).save(any(Publication.class));
}
```

=== Delete a record and verify it has been removed
```java
@Test
void deletePublicationAndVerifyRemoval() throws Exception {
  Long pubId = 1L;
  mockMvc.perform(delete("/api/pub/{id}", pubId))
    .andExpect(status().isOk());
  verify(publicationsService).deleteById(pubId);
}
```

=== Updating non-existent records

```java
@Test
void updateNonExistentPublication() throws Exception {
  Long nonExistentId = 999L;
  when(publicationsService.findById(nonExistentId)).thenReturn(null);
  mockMvc.perform(put("/api/pub/{id}", nonExistentId)
    .contentType(MediaType.APPLICATION_JSON)
    .content("{\"doi\":\"10.1000/nonexistent\"}"))
    .andExpect(status().isNotFound());
  verify(publicationsService, never()).save(any(Publication.class));
}
```

*Evaluation*: Compare the database state before and after each operation. Verify that the API returns the expected results and that the database reflects the changes accurately.

== Data Consistency
Guarantee synchronization and consistency between frontend and backend data.

=== Perform a create operation on the frontend and verify the data is correctly stored in the backend

```javascript
test('1. Creates a new scholar and verifies backend storage', async () => {
    const mockOnSelectScholar = jest.fn()
    render(<Scholars onSelectScholar={mockOnSelectScholar} />)
    const newScholar = {
        name: 'John Doe',
        major: 'Computer Science',
        hindex: '10',
        location: 'University of Example'
    }
    fireEvent.change(screen.getByTestId('new-scholar-name'), { target: { value: newScholar.name } })
    fireEvent.change(screen.getByTestId('new-scholar-major'), { target: { value: newScholar.major } })
    fireEvent.change(screen.getByTestId('new-scholar-hindex'), { target: { value: newScholar.hindex } })
    fireEvent.change(screen.getByTestId('new-scholar-location'), { target: { value: newScholar.location } })
    axios.post.mockResolvedValueOnce({ data: newScholar })
    fireEvent.click(screen.getByTestId('add-new-scholar-button'))
    await waitFor(() => {
        expect(axios.post).toHaveBeenCalledWith('http://localhost:8080/api/scholar/add', null, { params: newScholar })
    })
})
```

=== Search for a scholar and verify the frontend-backend data consistency

```javascript
test('2. Updates scholar data and confirms backend reflection', async () => {
    const mockOnSelectScholar = jest.fn()
    axios.get.mockResolvedValueOnce({
        data: [
            [1, 'John Doe', 'Computer Science', 10]
        ]
    })
    render(<Scholars onSelectScholar={mockOnSelectScholar} />)
    fireEvent.click(screen.getByText('Search'))
    await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument()
    })
    fireEvent.click(screen.getByText('John Doe'))
    expect(mockOnSelectScholar).toHaveBeenCalledWith(1)
})
```

=== Filter scholars with specific criteria and verify backend API call

```javascript
test('3. Fetches scholars with no grants and ensures backend removal', async () => {
    const mockOnSelectScholar = jest.fn()
    render(<Scholars onSelectScholar={mockOnSelectScholar} />)


    fireEvent.click(screen.getByLabelText(/Only Publications No Grants/i))
    fireEvent.click(screen.getByText(/Search/i))


    await waitFor(() => {
        expect(axios.get).toHaveBeenCalledWith('http://localhost:8080/api/scholar/publications-no-grants', expect.any(Object))
    })
})
```

=== Test different sorting criteria for scholars and verify corresponding backend calls

```javascript
test('4. Tests sorting scholars by different criteria', async () => {
    const mockOnSelectScholar = jest.fn()
    render(<Scholars onSelectScholar={mockOnSelectScholar} />)


    fireEvent.change(screen.getByLabelText(/Sort By/i), { target: { value: 'hindex' } })
    fireEvent.click(screen.getByText(/Search/i))


    await waitFor(() => {
        expect(axios.get).toHaveBeenCalledWith('http://localhost:8080/api/scholar/hindex', expect.any(Object))
    })
})
```

=== Simulate network interruptions during data transfer and test recovery mechanisms

```javascript
test('5. Simulates network error and tests error handling', async () => {
    const mockOnSelectScholar = jest.fn()
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => { });
    axios.get.mockRejectedValueOnce(new Error('Network Error'))
    render(<Scholars onSelectScholar={mockOnSelectScholar} />)
    fireEvent.click(screen.getByText(/Search/i))
    await waitFor(() => {
        expect(consoleSpy).toHaveBeenCalledWith('Error fetching scholars:', expect.any(Error));
    });
    consoleSpy.mockRestore();
});
```

== Performance
Test the response time of database operations.

=== Measure response time for querying a large dataset
```java
public void testLargeDatasetQuery() {
    long startTime = System.currentTimeMillis();
    jdbcTemplate.query("SELECT p.name, p.major, l.loc_name, l.country FROM people p JOIN \"in\" i ON p.pid = i.pid JOIN locations l ON i.locid = l.locid", (rs, rowNum) -> null);
    long endTime = System.currentTimeMillis();

    long duration = endTime - startTime;
    System.out.println("Large dataset query time: " + duration + " ms");
    assertTrue(duration < 5000, "Query took too long");
}
```

=== Test the system's ability to handle multiple concurrent database connections

```java
@Test
public void testConcurrentConnections() throws InterruptedException {
    int numThreads = 10;
    ExecutorService executorService = Executors.newFixedThreadPool(numThreads);
    long startTime = System.currentTimeMillis();
    for (int i = 0; i < numThreads; i++) {
        executorService.submit(() -> jdbcTemplate.query("SELECT p.name, pub.doi FROM people p JOIN publish pu ON p.pid = pu.pid JOIN publications pub ON pu.pubid = pub.pubid LIMIT 100", (rs, rowNum) -> null));
    }
    executorService.shutdown();
    executorService.awaitTermination(1, TimeUnit.MINUTES);
    long endTime = System.currentTimeMillis();
    long duration = endTime - startTime;
    System.out.println("Concurrent connections query time: " + duration + " ms");
    assertTrue(duration < 10000, "Concurrent queries took too long");
}
```

=== Evaluate the performance of complex join operations or aggregations

```java
@Test
public void testComplexJoinOperation() {
    long startTime = System.currentTimeMillis();
    jdbcTemplate.query(
            "SELECT p.name, p.major, l.loc_name, pub.doi, g.budget_start " +
                    "FROM people p " +
                    "JOIN \"in\" i ON p.pid = i.pid " +
                    "JOIN locations l ON i.locid = l.locid " +
                    "JOIN publish pu ON p.pid = pu.pid " +
                    "JOIN publications pub ON pu.pubid = pub.pubid " +
                    "LEFT JOIN has h ON p.pid = h.pid " +
                    "LEFT JOIN grants g ON h.grantid = g.grantid",
            (rs, rowNum) -> null);
    long endTime = System.currentTimeMillis();

    long duration = endTime - startTime;
    System.out.println("Complex join operation time: " + duration + " ms");
    assertTrue(duration < 7000, "Complex join took too long");
}
```

=== Measure the impact of indexing on query performance

```java
@Test
public void testIndexImpact() {
    // Assuming 'name' column is not indexed
    long startTimeWithoutIndex = System.currentTimeMillis();
    jdbcTemplate.query("SELECT * FROM people WHERE name = 'John Doe'", (rs, rowNum) -> null);
    long endTimeWithoutIndex = System.currentTimeMillis();

    // Now add an index (this should be done in a separate migration script in
    // practice)
    jdbcTemplate.execute("CREATE INDEX IF NOT EXISTS idx_people_name ON people(name)");

    long startTimeWithIndex = System.currentTimeMillis();
    jdbcTemplate.query("SELECT * FROM people WHERE name = 'John Doe'", (rs, rowNum) -> null);
    long endTimeWithIndex = System.currentTimeMillis();

    System.out.println("Query time without index: " + (endTimeWithoutIndex - startTimeWithoutIndex) + " ms");
    System.out.println("Query time with index: " + (endTimeWithIndex - startTimeWithIndex) + " ms");
    assertTrue((endTimeWithIndex - startTimeWithIndex) < (endTimeWithoutIndex - startTimeWithoutIndex),
            "Index did not improve performance");

    // Clean up: remove the index
    jdbcTemplate.execute("DROP INDEX IF EXISTS idx_people_name");
}
```

=== Test the system's performance under sustained load over an extended period

```java
@Test
public void testSustainedLoad() throws InterruptedException {
    ExecutorService executorService = Executors.newFixedThreadPool(5);
    long startTime = System.currentTimeMillis();

    for (int i = 0; i < 1000; i++) {
        executorService.submit(() -> jdbcTemplate.query(
                "SELECT p.name, p.major, l.loc_name, COUNT(pub.pubid) as publication_count " +
                        "FROM people p " +
                        "JOIN \"in\" i ON p.pid = i.pid " +
                        "JOIN locations l ON i.locid = l.locid " +
                        "LEFT JOIN publish pu ON p.pid = pu.pid " +
                        "LEFT JOIN publications pub ON pu.pubid = pub.pubid " +
                        "GROUP BY p.pid, l.locid " +
                        "ORDER BY publication_count DESC " +
                        "LIMIT 10",
                (rs, rowNum) -> null));
        Thread.sleep(100); // Simulate delay between requests
    }

    executorService.shutdown();
    executorService.awaitTermination(5, TimeUnit.MINUTES);
    long endTime = System.currentTimeMillis();

    long duration = endTime - startTime;
    System.out.println("Sustained load test time: " + duration + " ms");
    assertTrue(duration < 120000, "Sustained load test took too long");
}
```

*Evaluation*: Use performance testing tools to measure response times, throughput, and resource utilization. Compare results against predefined performance benchmarks.
