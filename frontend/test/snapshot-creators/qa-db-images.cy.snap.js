import {
  restore,
  snapshot,
  addPostgresDatabase,
  addMongoDatabase,
  addMySQLDatabase,
} from "__support__/cypress";
import {
  PG_DB_NAME,
  MONGO_DB_NAME,
  MYSQL_DB_NAME,
} from "__support__/cypress_data";

describe("qa databases", () => {
  beforeEach(() => {
    restore();
    cy.signInAsAdmin();
  });

  it("mysql", () => {
    addMySQLDatabase(MYSQL_DB_NAME);
    generateSnapshot("mysql");
  });

  it("postgres", () => {
    addPostgresDatabase(PG_DB_NAME);
    generateSnapshot("postgres");
  });

  it("mongo", () => {
    addMongoDatabase(MONGO_DB_NAME);
    generateSnapshot("mongo");
  });
});

function assertOnDatabase(engine) {
  cy.request("GET", "/api/database").then(({ body }) => {
    const { id } = body.find(db => {
      return db.engine === engine;
    });

    cy.wait(1000);
    cy.request("GET", `/api/database/${id}/metadata`).then(({ body }) => {
      cy.wrap(body.tables).should("have.length", 4);
    });
  });
}

function generateSnapshot(name) {
  assertOnDatabase(name);
  snapshot(name);
  restore("blank");
}
