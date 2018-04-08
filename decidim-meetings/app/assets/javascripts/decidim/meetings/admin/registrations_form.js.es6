// = require ./auto_label_by_position.component
// = require ./auto_buttons_by_position.component
// = require ./dynamic_fields.component

((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;

  const wrapperSelector = ".meeting-registration-questions";
  const fieldSelector = ".meeting-registration-question";

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".meeting-service:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".meeting-service:not(.hidden)",
    hideOnFirstSelector: ".move-up-service",
    hideOnLastSelector: ".move-down-service"
  });

  const createSortableList = () => {
    createSortList(".meeting-services-list:not(.published)", {
      handle: ".service-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: () => { autoLabelByPosition.run() }
    });
  };

  const hideDeletedQuestion = ($target) => {
    const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

    if (inputDeleted === "true") {
      $target.addClass("hidden");
      $target.hide();
    }
  };

  createDynamicFields({
    placeholderId: "meeting-registration-question-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".meeting-registration-questions-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-registration-question",
    removeFieldButtonSelector: ".remove-registration-question",
    moveUpFieldButtonSelector: ".move-up-registration-question",
    moveDownFieldButtonSelector: ".move-down-registration-question",
    onAddField: ($field) => {
      createSortableList();

      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onRemoveField: ($field) => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveUpField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveDownField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    }
  });

  createSortableList();

  $(fieldSelector).each((idx, el) => {
    const $target = $(el);

    hideDeletedQuestion($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
})(window);

$(() => {
  const $form = $(".edit_meeting_registrations");

  if ($form.length > 0) {
    const $registrationsEnabled = $form.find("#meeting_registrations_enabled");
    const $availableSlots = $form.find("#meeting_available_slots");
    const $reservedSlots = $form.find("#meeting_reserved_slots");

    const toggleDisabledFields = () => {
      const enabled = $registrationsEnabled.prop("checked");
      $availableSlots.attr("disabled", !enabled);
      $reservedSlots.attr("disabled", !enabled);

      $form.find(".editor-container").each((idx, node) => {
        const quill = Quill.find(node);
        quill.enable(enabled);
      })
    };

    $registrationsEnabled.on("change", toggleDisabledFields);
    toggleDisabledFields();
  }
});
